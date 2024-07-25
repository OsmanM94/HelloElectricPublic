//
//  EmptyView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct EmptyContentView: View {
    let message: String
    let systemImage: String
    
    var body: some View {
        ContentUnavailableView(label: {
            Label(message, systemImage: systemImage)
        })
    }
}

#Preview {
    EmptyContentView(message: "No listings saved", systemImage: "heart.slash.fill")
}
