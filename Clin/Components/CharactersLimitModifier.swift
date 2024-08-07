//
//  CharactersLimitModifier.swift
//  Clin
//
//  Created by asia on 09/07/2024.
//

import SwiftUI

struct CharacterLimitModifier: ViewModifier {
    @Binding var text: String
    let limit: Int
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
                .onChange(of: text) { _, newValue in
                    if text.count > limit {
                        text = String(text.prefix(limit))
                    }
                }
        }
    }
}

extension View {
    func characterLimit(_ text: Binding<String>, limit: Int) -> some View {
        self.modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}

