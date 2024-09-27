//
//  NotificationsView.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI

struct NotificationsView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 60) {
        
            Image(systemName: "hammer")
                .font(.system(size: 50))
            
            Text("Coming soon")
                .font(.title2)
                .fontDesign(.rounded).bold()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .padding(.bottom, 80)
        .navigationTitle("Notifications")
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
