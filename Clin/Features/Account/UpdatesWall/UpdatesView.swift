//
//  UpdatesView.swift
//  Clin
//
//  Created by asia on 12/09/2024.
//

import SwiftUI

struct UpdatesView: View {
    let features: [String] = ["Notifications", "Chat messaging", "Website"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What features are coming next?")
                .font(.title2)
                .fontDesign(.rounded).bold()
            
            ForEach(features.indices, id: \.self) { index in
                Text("\(index + 1). \(features[index])")
            }
        }
        .padding()
        .padding(.top)
        .navigationTitle("Updates")
        
        Spacer()
    }
}

#Preview {
    NavigationStack {
        UpdatesView()
    }
}
