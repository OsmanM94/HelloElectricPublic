//
//  TImerManager.swift
//  Clin
//
//  Created by asia on 03/08/2024.
//

import Foundation

@Observable
final class TimerManager {
    var startTimer: Date?
    private var timer: Timer?
    
    func startListingTimer(interval: TimeInterval = 60) {
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.startTimer = Date()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
