//
//  ShakeGesture.swift
//  Clin
//
//  Created by asia on 22/09/2024.
//

import SwiftUI

// Notification for shake gesture
extension NSNotification.Name {
    static let deviceDidShake = NSNotification.Name(rawValue: "deviceDidShake")
}

// UIWindow extension to detect shake gesture
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
    }
}

// Custom view modifier to detect shake gesture
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
                action()
            }
    }
}

// View extension to make it easier to use the shake gesture
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
