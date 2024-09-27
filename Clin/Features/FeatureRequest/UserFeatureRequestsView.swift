//
//  UserFeatureRequestsView.swift
//  Clin
//
//  Created by asia on 27/09/2024.
//

import SwiftUI

struct UserFeatureRequestsView: View {
    @Bindable var viewModel: FeatureRequestViewModel
    
    var body: some View {
        VStack {
            switch viewModel.userViewState {
            case .empty:
                ErrorView(
                    message: "You haven't submitted any feature requests yet.",
                    refreshMessage: "Refresh",
                    retryAction: {
                        Task { await viewModel.loadUserFeatureRequests() }
                    },
                    systemImage: "tray.fill"
                )
            case .loading:
                CustomProgressView(message: "Loading...")
                
            case .success:
                mainContent
                
            case .error(let message):
                ErrorView(
                    message: message,
                    refreshMessage: "Try again",
                    retryAction: {
                        Task { await viewModel.loadUserFeatureRequests() }
                    },
                    systemImage: "xmark.circle.fill"
                )
            }
        }
        .task {
            if viewModel.userFeatures.isEmpty {
                await viewModel.loadUserFeatureRequests()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.userViewState)
    }
    
    private var mainContent: some View {
        List {
            ForEach(viewModel.userFeatures, id: \.id) { feature in
                NavigationLink(
                    destination: FeatureRequestDetailView(
                        viewModel: viewModel,
                        request: feature
                    )
                ) {
                    FeatureRequestRow(
                        viewModel: viewModel,
                        request: feature
                    )
                }
            }
            .onDelete(perform: viewModel.deleteFeature)
        }
        .refreshable { await viewModel.loadUserFeatureRequests() }
        .navigationTitle("My Requests")
        .toolbar { EditButton() }
    }
}

#Preview {
    NavigationStack {
        UserFeatureRequestsView(viewModel: FeatureRequestViewModel())
    }
}
