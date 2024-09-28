//
//  FeatureRequestListView.swift
//  Clin
//
//  Created by asia on 27/09/2024.
//

import SwiftUI

struct FeatureRequestListView: View {
    @State private var viewModel = FeatureRequestViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .loading:
                    CustomProgressView(message: "")
                    
                case .loaded:
                    MainContentView(viewModel: viewModel)
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        refreshMessage: "Try again",
                        retryAction: { Task { await viewModel.loadFeatureRequests() } },
                        systemImage: "xmark.circle.fill"
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .toolbar {
                Menu {
                    NavigationLink(destination: NewFeatureRequestView(viewModel: viewModel)) {
                        Text("Add request")
                    }
                    
                    NavigationLink {
                        UserFeatureRequestsView(viewModel: viewModel)
                    } label: {
                        Text("My requests")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.tabColour)
                }
            }
            .navigationTitle("Feature Requests")
        }
        .task {
            if viewModel.features.isEmpty {
                await viewModel.loadFeatureRequests()
            }
        }
    }
}

fileprivate struct MainContentView: View {
    @Bindable var viewModel: FeatureRequestViewModel
    
    var body: some View {
        Picker("Status", selection: $viewModel.selectedStatus) {
            Text("Pending").tag(FeatureRequestStatus.pending)
            Text("Approved").tag(FeatureRequestStatus.approved)
            Text("Rejected").tag(FeatureRequestStatus.rejected)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        
        List {
            ForEach(viewModel.filteredRequests, id: \.id) { request in
                NavigationLink(
                    destination: FeatureRequestDetailView(
                        viewModel: viewModel,
                        request: request
                    )
                ) {
                    FeatureRequestRow(
                        viewModel: viewModel,
                        request: request
                    )
                }
            }
        }
        .overlay(
            Group {
                if viewModel.filteredRequests.isEmpty {
                    Text("No \(viewModel.selectedStatus.rawValue.lowercased()) requests")
                        .foregroundStyle(.secondary)
                }
            }
        )
        .refreshable {
            await viewModel.loadFeatureRequests()
        }
    }
}

#Preview {
    FeatureRequestListView()
}
