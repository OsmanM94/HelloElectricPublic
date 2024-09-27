//
//  FeatureRequestRow.swift
//  Clin
//
//  Created by asia on 27/09/2024.
//

import SwiftUI

struct FeatureRequestRow: View {
    @Bindable var viewModel: FeatureRequestViewModel
    let request: FeatureRequest
    
    @State private var hasVoted: Bool = false
    @State private var isVoting: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(request.title)
                .font(.headline)
            
            Text(request.name ?? "Not provided")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(request.status.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(viewModel.statusColor(for: request.status))
                
                Spacer()
                
                Text("Votes: \(request.voteCount)")
                    .font(.caption)
                
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
                    Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                }
                .disabled(isVoting)
                .buttonStyle(.bordered)
            }
        }
        .task {
            if let userId = try? await viewModel.supabaseService.client.auth.session.user.id {
                hasVoted = request.hasVoted(userId: userId)
            }
        }
    }
}

#Preview {
    FeatureRequestRow(viewModel: FeatureRequestViewModel(), request: FeatureRequest(id: 1, name: "John", title: "Chat", description: "I would like a chat messaging", status: FeatureRequestStatus(rawValue: "Approved")!, createdAt: Date.now, comments: "I will implement this feature, thanks", userId: UUID(), voteCount: 1, votedUserIds: []))
}
