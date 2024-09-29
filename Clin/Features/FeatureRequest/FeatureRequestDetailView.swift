//
//  FeatureRequestDetailView.swift
//  Clin
//
//  Created by asia on 27/09/2024.
//

import SwiftUI

struct FeatureRequestDetailView: View {
    @Bindable var viewModel: FeatureRequestViewModel
    let request: FeatureRequest
    @State private var hasVoted: Bool = false
    @State private var isVoting: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title and Description
                VStack(alignment: .leading, spacing: 12) {
                    Text(request.title)
                        .font(.title)
                        .fontDesign(.rounded)
                    
                    Text(request.description)
                        .font(.body)
                }
                
                Divider()
                
                // Status and Metadata
                VStack(alignment: .leading, spacing: 8) {
                    StatusView(status: request.status, statusColor: viewModel.statusColor(for: request.status))
                    
                    Text("Submitted by: \(request.name ?? "Not provided")")
                        .font(.subheadline)
                    
                    Text("Submitted on: \(request.createdAt.formattedString())")
                        .font(.subheadline)
                    
                    HStack {
                        Text("Request ID: \(request.id ?? 0)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        ReportButton(itemId: request.id ?? 0, itemType: "request", iconSize: 15)
                    }
                }
                
                Divider()
                
                // Voting Section
                HStack {
                    Text("Votes: \(request.voteCount)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        guard !isVoting else { return }
                        isVoting = true
                        Task {
                            if hasVoted {
                                await viewModel.unvote(for: request)
                            } else {
                                await viewModel.vote(for: request)
                            }
                            hasVoted.toggle()
                            isVoting = false
                        }
                    }) {
                        HStack {
                            Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                            Text(hasVoted ? "Voted" : "Vote")
                        }
                    }
                    .disabled(isVoting)
                    .buttonStyle(.bordered)
                }
                
                if let comments = request.comments, !comments.isEmpty {
                    Divider()
                    AdminCommentsView(comments: comments)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let userId = try? await viewModel.supabaseService.client.auth.session.user.id {
                hasVoted = request.votedUserIds.contains(userId)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeatureRequestDetailView(viewModel: FeatureRequestViewModel(), request: FeatureRequest(id: 1, name: "John", title: "Chat", description: "I would like a chat messaging", status: FeatureRequestStatus(rawValue: "Pending")!, createdAt: Date.now, comments: "I will implement this feature soon, thank you.", userId: UUID(), voteCount: 1, votedUserIds: []))
    }
}

fileprivate struct StatusView: View {
    let status: FeatureRequestStatus
    let statusColor: Color
    
    var body: some View {
        HStack {
            Text("Status:")
                .font(.headline)
            Text(status.rawValue)
                .font(.headline)
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}


fileprivate struct AdminCommentsView: View {
    let comments: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Admin Comments")
                .font(.headline)
                .foregroundStyle(.primary)
            
            if let comments = comments, !comments.isEmpty {
                Text(comments)
                    .font(.body)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Text("No comments")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }
}
