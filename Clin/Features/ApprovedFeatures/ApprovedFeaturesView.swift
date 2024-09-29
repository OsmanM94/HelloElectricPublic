//
//  UpdatesView.swift
//  Clin
//
//  Created by asia on 12/09/2024.
//

import SwiftUI

struct ApprovedFeaturesView: View {
    @State private var viewModel = ApprovedFeaturesViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .empty:
                ErrorView(
                    message: "Empty",
                    refreshMessage: "Refresh",
                    retryAction: { Task { await viewModel.loadFeatures() } },
                    systemImage: "tray.fill"
                )
            case .loading:
                CustomProgressView(message: "")
                
            case .loaded:
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        upcomingFeaturesSection
                        featuresList
                        timelineSection
                        feedbackSection
                    }
                    .padding()
                }
                
            case .error(let message):
                ErrorView(
                    message: message,
                    refreshMessage: "Try again",
                    retryAction: { Task { await viewModel.loadFeatures() } },
                    systemImage: "xmark.circle.fill"
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .navigationTitle("Approved features")
        .task {
            if viewModel.features.isEmpty {
                await viewModel.loadFeatures()
            }
        }
    }
    
    private var upcomingFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("We're constantly working to improve your experience. Here's what's coming next:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(viewModel.features) { feature in
                ApprovedFeatureRow(feature: feature)
            }
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Development Timeline")
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            Text("As this platform is developed by a single passionate developer, the timeline for new features may be longer than for larger teams. We appreciate your patience and support!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Our goal is to release a new major feature every 1-4 months, but this may vary based on complexity and user feedback.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Voice Matters")
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            Text("We value your input! If you have ideas for new features or improvements, please don't hesitate to share them with us.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            NavigationLink {
                SupportCenterView()
            } label: {
                Text("Get in touch")
                    .foregroundStyle(.tabColour)
                    .padding()
                    .background(Color.tabColour.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ApprovedFeaturesView()
    }
}
