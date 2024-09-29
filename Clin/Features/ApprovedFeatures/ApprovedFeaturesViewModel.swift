//
//  ApprovedFeaturesViewModel.swift
//  Clin
//
//  Created by asia on 29/09/2024.
//

import Foundation
import Factory

@Observable
final class ApprovedFeaturesViewModel {
    
    enum ViewState: Equatable {
        case empty
        case loading
        case loaded
        case error(String)
    }
    
    var features: [ApprovedFeature] = []
    var isLoading = false
    var viewState: ViewState = .loading
    var errorMessage: String?
    
    @ObservationIgnored @Injected(\.databaseService) private var databaseService
    
    @MainActor
    func loadFeatures() async {
        self.viewState = .loading

        do {
            self.features = try await databaseService.loadAllItems(from: "approved_features", orderBy: "created_at", ascending: true)
            
            self.viewState = features.isEmpty ? .empty : .loaded
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
}
