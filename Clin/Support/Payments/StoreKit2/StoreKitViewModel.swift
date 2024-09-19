//
//  StoreKitViewModel.swift
//  Clin
//
//  Created by asia on 05/09/2024.
//

import Foundation
import StoreKit

enum PurchaseViewState: Equatable {
    case ready
    case purchasing
    case completed
    case failed(String)
}

enum StoreError: Error {
    case failedVerification
    case productNotAvailable
    case purchaseFailed(underlying: Error)
    case networkError
    case userCancelled
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotAvailable:
            return "Product is not available"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error)"
        case .networkError:
            return "Network error occurred"
        case .userCancelled:
            return "Purchase was cancelled by the user"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

@Observable
final class StoreKitViewModel {
    var product: Product?
    let productName: String = "promote2weeks"
    var viewState: PurchaseViewState = .ready
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = configureTransactionListener()
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    @MainActor
    func purchase() async {
        guard let product = product else {
            viewState = .failed(StoreError.productNotAvailable.localizedDescription)
            return
        }
        
        do {
            viewState = .purchasing
            let result = try await product.purchase()
            try await handlePurchase(from: result)
        } catch {
            viewState = .failed(StoreError.purchaseFailed(underlying: error).localizedDescription)
        }
    }
    
    @MainActor
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productName])
            if let product = products.first {
                self.product = product
                viewState = .ready
            } else {
                viewState = .failed(StoreError.productNotAvailable.localizedDescription)
            }
        } catch {
            viewState = .failed(StoreError.networkError.localizedDescription)
        }
    }
    
    private func configureTransactionListener() -> Task<Void, Error> {
        Task { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)
                    self?.viewState = .completed
                    
                    await transaction?.finish()
                } catch {
                    self?.viewState = .failed(StoreError.failedVerification.localizedDescription)
                }
            }
        }
    }
    
    @MainActor
    private func handlePurchase(from result: Product.PurchaseResult) async throws {
        switch result {
        case .success(let verification):
            let transaction =  try checkVerified(verification)
            viewState = .completed
            await transaction.finish()
            
        case .pending:
            viewState = .purchasing
            
        case .userCancelled:
            viewState = .ready
            
        @unknown default:
            viewState = .failed("DEBUG: Unknown error occurred")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
            
        case .verified(let safe):
            return safe
        }
    }
}
