//
//  SearchableView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct TextFieldSearchView: View {
    @State var disableTextInput: Bool
    @Binding var search: String
    
    let action: () async -> Void
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            
            TextField("", text: $search, prompt: Text("Search").foregroundStyle(.gray))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .padding(.vertical, 8)
                .onSubmit {
                    guard !search.isEmpty else { return }
                    Task {
                        await action()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .disabled(disableTextInput)
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        TextFieldSearchView(disableTextInput: false, search: .constant(""), action: {})
            .previewLayout(.sizeThatFits)
    }
}
