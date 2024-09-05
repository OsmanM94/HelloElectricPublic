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
            return "Purchase failed: \(error.localizedDescription)"
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
    var viewState: PurchaseViewState = .ready {
        didSet {
            Logger.info("ViewState changed to: \(viewState)")
        }
    }
    private var transactionListener: Task<Void, Error>?
    
    init() {
        Logger.debug("Initializing StoreKitViewModel")
        transactionListener = configureTransactionListener()
    }
    
    deinit {
        Logger.debug("Deinitializing StoreKitViewModel")
        transactionListener?.cancel()
    }
    
    @MainActor
    func purchase() async {
        Logger.info("Starting purchase process")
        guard let product = product else {
            Logger.error("Attempt to purchase with no product available")
            viewState = .failed(StoreError.productNotAvailable.localizedDescription)
            return
        }
        
        do {
            viewState = .purchasing
            Logger.info("Initiating purchase for product: \(product.id)")
            let result = try await product.purchase()
            try await handlePurchase(from: result)
        } catch {
            Logger.error("Purchase failed: \(error)")
            viewState = .failed(StoreError.purchaseFailed(underlying: error).localizedDescription)
        }
    }
    
    @MainActor
    func loadProducts() async {
        Logger.info("Loading products")
        do {
            let products = try await Product.products(for: [productName])
            if let product = products.first {
                self.product = product
                viewState = .ready
                Logger.info("Product loaded successfully: \(product.id)")
            } else {
                Logger.error("No products available")
                viewState = .failed(StoreError.productNotAvailable.localizedDescription)
            }
        } catch {
            viewState = .failed(StoreError.networkError.localizedDescription)
            Logger.error("Failed to load products: \(error)")
        }
    }
    
    private func configureTransactionListener() -> Task<Void, Error> {
        Task { [weak self] in
            for await result in Transaction.updates {
                do {
                    Logger.debug("Received transaction update")
                    let transaction = try self?.checkVerified(result)
                    self?.viewState = .completed
                    await transaction?.finish()
                    Logger.info("Transaction completed successfully")
                } catch {
                    Logger.error("Transaction verification failed: \(error)")
                    self?.viewState = .failed(StoreError.failedVerification.localizedDescription)
                }
            }
        }
    }
    
    @MainActor
    private func handlePurchase(from result: Product.PurchaseResult) async throws {
        switch result {
        case .success(let verification):
            Logger.info("Purchase successful, verifying transaction")
            let transaction =  try checkVerified(verification)
            viewState = .completed
            await transaction.finish()
            Logger.info("Purchase completed and verified")
        case .pending:
            Logger.info("Purchase is pending")
            viewState = .purchasing
        case .userCancelled:
            Logger.info("Purchase cancelled by user")
            viewState = .ready
        @unknown default:
            Logger.error("Unknown purchase result")
            viewState = .failed("DEBUG: Unknown error occurred")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            Logger.error("Verification failed")
            throw StoreError.failedVerification
        case .verified(let safe):
            Logger.debug("Verification successful")
            return safe
        }
    }
}
