//
//  UpdatesView.swift
//  Clin
//
//  Created by asia on 12/09/2024.
//

import SwiftUI

struct UpdatesView: View {
    let features: [String] = ["Notifications", "Chat", "Performance improvements"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 60) {
        
            Image(systemName: "hammer")
                .font(.system(size: 50))
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("What features are coming next?")
                    .font(.title2)
                    .fontDesign(.rounded).bold()
                
                ForEach(features.indices, id: \.self) { index in
                    Text("\(index + 1). \(features[index])")
                }
            }
        }
        .padding()
        .padding(.bottom, 80)
        .navigationTitle("Upcoming updates")
    }
}

#Preview {
    NavigationStack {
        UpdatesView()
    }
}
