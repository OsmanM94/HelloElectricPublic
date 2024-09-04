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
final class NotificationManager {
    @ObservationIgnored @Injected(\.supabaseService) private var supabase
    
    init() {
        setupRealtimeListener()
    }
    
    func setupRealtimeListener()  {
        Task {
            let channel = supabase.client.channel("new_car_listing")
            let insertions = channel.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "car_listing"
            )
            
            
            await channel.subscribe()
            print("Successfully subscribed to the channel.")
            for await insert in insertions {
                print("Received new insertion: \(insert)")
                let record = insert.record
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: record)
                    let newCarListing = try JSONDecoder().decode(Listing.self, from: jsonData)
                    print("Decoded new car listing: \(newCarListing)")
                    scheduleNotification(for: newCarListing)
                } catch {
                    print("Error decoding listing: \(error)")
                }
            }
            
        }
    }
    
    private func scheduleNotification(for listing: Listing) {
        let content = UNMutableNotificationContent()
        content.title = "New listing added"
        content.subtitle = "\(listing.make) \(listing.model) - £\(listing.price)"
        content.body = "\(listing.condition) condition, \(listing.mileage) miles, Located in \(listing.location)"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
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
