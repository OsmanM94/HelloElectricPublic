//
//  SearchBarView.swift
//  Clin
//
//  Created by asia on 14/09/2024.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSubmit: () async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField("", text: $searchText, prompt: Text("Search").foregroundStyle(.gray))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .padding(.vertical, 8)
                    .onSubmit {
                        guard !searchText.isEmpty else { return }
                        Task {
                            await onSubmit()
                        }
                    }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
}

#Preview {
    SearchBarView(searchText: .constant(""), onSubmit: {})
}
