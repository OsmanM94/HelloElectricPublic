//
//  NotificationManager.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI
import UserNotifications
import Realtime
import Factory


@Observable
final class NotificationsViewModel {
    @ObservationIgnored @Injected(\.supabaseService) private var supabase
   
    var newListings: [Notification] = []
   
    init() {
        setupRealtimeListener()
    }
    
    private func setupRealtimeListener() {
        Task {
            let channel = supabase.client.channel("car_listing_insertions")
            let changeStream = channel.postgresChange(InsertAction.self, table: "car_listing")
            
            await channel.subscribe()
            
            for await insert in changeStream {
                print("Received record: \(insert.record)")
                if let newListing = try? insert.decodeRecord(as: Notification.self, decoder: JSONDecoder()) {
                    print("Inserted: \(newListing)")
                    
                    DispatchQueue.main.async {
                        self.sendNotification(for: newListing)
                    }
                } else {
                    print("Failed to decode the listing record.")
                }
            }
        }
    }
    
    private func sendNotification(for listing: Notification) {
        let content = UNMutableNotificationContent()
        content.title = "New Car Listing: \(listing.make) \(listing.model)"
        content.body = "Year: \(listing.year)\nPrice: \(listing.price)\nLocation: \(listing.location)"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to add notification request: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(listing.make) \(listing.model)")
            }
        }
    }
   
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permissions granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
}

    


