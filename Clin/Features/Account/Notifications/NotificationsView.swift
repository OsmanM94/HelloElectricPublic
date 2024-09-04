//
//  NotificationsView.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @State private var manager = NotificationManager()
    
    var body: some View {
        VStack {
            Button("Press me") {
                let content = UNMutableNotificationContent()
                content.title = "Alexandra..."
                content.subtitle = "Mi-e foame sefa mea suprema"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
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
