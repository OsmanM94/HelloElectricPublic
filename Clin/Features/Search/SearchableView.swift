//
//  SearchableView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchableView: View {
    @Binding var search: String
    @State var disableTextInput: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            
            TextField("", text: $search, prompt: Text("Search").foregroundStyle(.gray))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .padding(.vertical, 8)
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
        SearchableView(search: .constant(""), disableTextInput: false)
            .previewLayout(.sizeThatFits)
    }
}
