//
//  UpdatesView.swift
//  Clin
//
//  Created by asia on 12/09/2024.
//

import SwiftUI

struct UpdatesView: View {
    private let features: [Feature] = [
        Feature(name: "Notifications", description: "Get instant alerts for new listings and messages.", eta: "Q1 2025"),
        Feature(name: "Chat messaging", description: "Communicate directly with sellers within the app.", eta: "Q2 2025"),
        Feature(name: "CarPlay Support", description: "Access key app features while driving.", eta: "Q3 2025"),
        Feature(name: "Website", description: "Browse and manage listings from your computer.", eta: "Q4 2025"),
        Feature(name: "Advanced Search Filters", description: "Find your perfect EV with precision.", eta: "Q4 2025")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                upcomingFeaturesSection
                timelineSection
                feedbackSection
            }
            .padding()
        }
        .navigationTitle("Future Updates")
    }
    
    private var upcomingFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Exciting Features on the Horizon")
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            Text("We're constantly working to improve your experience. Here's what's coming next:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(features) { feature in
                FeatureRow(feature: feature)
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
            }
        }
    }
}

fileprivate struct Feature: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let eta: String
    
    var friendlyETA: String {
      /*
       Q1 (First Quarter): January, February, March
       Q2 (Second Quarter): April, May, June
       Q3 (Third Quarter): July, August, September
       Q4 (Fourth Quarter): October, November, December
       */
        
        switch eta {
        case "Q1 2025": return "Jan - Mar 2025"
        case "Q2 2025": return "Apr - Jun 2025"
        case "Q3 2025": return "Jul - Sep 2025"
        case "Q4 2025": return "Oct - Dec 2025"
        default: return eta
        }
    }
}

fileprivate struct FeatureRow: View {
    let feature: Feature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(feature.name)
                .font(.headline)
            Text(feature.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Expected: \(feature.friendlyETA)")
                .font(.caption)
                .foregroundStyle(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        UpdatesView()
    }
}
