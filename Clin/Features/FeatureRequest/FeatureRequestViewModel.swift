//
//  FeatureRequestViewModel.swift
//  Clin
//
//  Created by asia on 27/09/2024.
//

import SwiftUI
import Factory

@Observable
final class FeatureRequestViewModel {
    
    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
    }
    
    enum NewRequestViewState: Equatable {
        case loaded
        case success
        case error(String)
    }
    
    enum UserRequestViewState: Equatable {
        case empty
        case loading
        case success
        case error(String)
    }
    
    var features: [FeatureRequest] = []
    var userFeatures: [FeatureRequest] = []
    var selectedStatus: FeatureRequestStatus = .pending
    
    var viewState: ViewState = .loading
    var userViewState : UserRequestViewState = .loading
    var newRequestViewState : NewRequestViewState = .loaded
    
    var name: String = "Annonymous"
    var title: String = ""
    var description: String = ""
    
    @ObservationIgnored @Injected(\.supabaseService)  var supabaseService
    @ObservationIgnored @Injected(\.databaseService) private var databaseService
    
    var filteredRequests: [FeatureRequest] {
        features.filter { request in
            switch self.selectedStatus {
            case .pending:
                return request.pending
            case .approved:
                return request.approved
            case .rejected:
                return request.rejected
            }
        }
    }
    
    @MainActor
    func createFeatureRequest() async {
        self.newRequestViewState = .loaded
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                self.userViewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
                return
            }
            
            let newFeature = FeatureRequest(
                id: nil,
                name: self.name,
                title: self.title,
                description: self.description,
                pending: true,
                approved: false,
                rejected: false,
                createdAt: Date.now,
                comments: nil,
                userId: user.id,
                voteCount: 0,
                votedUserIds: []
            )
            
            try await databaseService.insertItem(newFeature, into: "feature_request")
            
            self.features.append(newFeature)
            
            self.name = ""
            self.title = ""
            self.description = ""
            
            self.newRequestViewState = .success
        
        } catch {
            self.newRequestViewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
        
    @MainActor
    func vote(for featureRequest: FeatureRequest) async {
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                self.userViewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
                return
            }
            
            guard let id = featureRequest.id else {
                return
            }
            
            if !featureRequest.votedUserIds.contains(user.id) {
                var updatedRequest = featureRequest
                updatedRequest.voteCount += 1
                updatedRequest.votedUserIds.append(user.id)
                
                try await databaseService.updateItemByID(updatedRequest, in: "feature_request", id: id)
                
                if let index = features.firstIndex(where: { $0.id == id }) {
                    features[index] = updatedRequest
                }
                if let userIndex = userFeatures.firstIndex(where: { $0.id == id }) {
                    userFeatures[userIndex] = updatedRequest
                }
            }
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func unvote(for featureRequest: FeatureRequest) async {
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                self.userViewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
                return
            }
            
            guard let id = featureRequest.id else {
                return
            }
            
            if featureRequest.votedUserIds.contains(user.id) {
                var updatedRequest = featureRequest
                updatedRequest.voteCount -= 1
                updatedRequest.votedUserIds.removeAll { $0 == user.id }
                
                try await databaseService.updateItemByID(updatedRequest, in: "feature_request", id: id)
                
                if let index = features.firstIndex(where: { $0.id == id }) {
                    features[index] = updatedRequest
                }
                if let userIndex = userFeatures.firstIndex(where: { $0.id == id }) {
                    userFeatures[userIndex] = updatedRequest
                }
            }
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func resetRequestState() {
        self.newRequestViewState = .loaded
    }
    
    @MainActor
    func resetFields() {
        self.name = ""
        self.title = ""
        self.description = ""
        self.newRequestViewState = .loaded
    }
    
    @MainActor
    func loadFeatureRequests() async {
        self.features.removeAll()
        self.viewState = .loading
        
        do {
            let loadedFeatures: [FeatureRequest] = try await databaseService.loadAllItems(from: "feature_request", orderBy: "vote_count", ascending: false)
            
            self.features = loadedFeatures
            self.viewState = .loaded
            
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func loadUserFeatureRequests() async {
        self.userViewState = .loading
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                self.userViewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
                return
            }
            
            let userFeatures: [FeatureRequest] = try await databaseService.loadItemsByField(
                from: "feature_request",
                orderBy: "created_at",
                ascending: false,
                field: "user_id",
                uuid: user.id
            )
            
            self.userFeatures = userFeatures
            self.userViewState = userFeatures.isEmpty ? .empty : .success
            
        } catch {
            self.userViewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    private func deleteFeatureRequest(_ feature: FeatureRequest) async {
        do {
            guard let id = feature.id else {
                return
            }
            
            try await databaseService.deleteItemByID(from: "feature_request", id: id)
            
            // Remove the deleted feature from both arrays
            self.features.removeAll { $0.id == id }
            self.userFeatures.removeAll { $0.id == id }
            
            if self.userFeatures.isEmpty {
                self.userViewState = .empty
            }
        } catch {
            self.userViewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func deleteFeature(at offsets: IndexSet) {
        for index in offsets {
            let feature = userFeatures[index]
            Task {
                await deleteFeatureRequest(feature)
                await loadFeatureRequests()
            }
        }
    }
    
    @MainActor
    func statusColor(for status: FeatureRequestStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
}
