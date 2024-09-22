//
//  UserListingsPublicViewModel.swift
//  Clin
//
//  Created by asia on 21/09/2024.
//

import Foundation
import Factory


@Observable
final class PublicUserListingsViewModel {
    enum ViewState: Equatable {
        case empty
        case loading
        case success
        case error(String)
    }
    
    private(set) var listings: [Listing] = []
    private(set) var viewState: ViewState = .loading
    
    var sellerID: UUID?
    
    init(sellerID: UUID) {
        self.sellerID = sellerID
    }
    
    @ObservationIgnored @Injected(\.listingService) private var listingService
    
    @MainActor
    func loadListings() async {
        do {
            let listings = try await listingService.loadUserListings(userID: self.sellerID ?? UUID())
            
            self.listings = listings
            self.viewState = listings.isEmpty ? .empty : .success
            
        } catch {
            self.viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
}
