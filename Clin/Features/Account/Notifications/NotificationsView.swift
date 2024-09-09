//
//  NotificationsView.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @State private var manager = NotificationsViewModel()
    
    var body: some View {
        VStack {
            Text("Listings count: \(manager.newListings.count)")
            List(manager.newListings) { listing in
                VStack(alignment: .leading) {
                    Text("\(listing.make) \(listing.model)")
                        .font(.headline)
                }
            }
        }
        .onAppear {
            manager.requestNotificationPermissions()
        }
    }
}

#Preview {
    NotificationsView()
}
