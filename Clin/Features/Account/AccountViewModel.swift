//
//  AccountViewModel.swift
//  Clin
//
//  Created by asia on 16/09/2024.
//

import SwiftUI

@Observable
final class AccountViewModel {
    var navigationHaptic: Bool {
        get {
            access(keyPath: \.navigationHaptic)
            return UserDefaults.standard.bool(forKey: "navigationHaptic")
        }
        set {
            withMutation(keyPath: \.navigationHaptic) {
                UserDefaults.standard.setValue(newValue, forKey: "navigationHaptic")
            }
        }
    }
    
    func navigationSensoryFeedback(intensity: CGFloat = 0.5) {
        /// Values closer to 0 will result in a very subtle feedback, while values closer to 1 will make the soft feedback more noticeable, but still within the "soft" range.
        if navigationHaptic {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.prepare()
            
            // Clamp the intensity between 0 and 1
            let clampedIntensity = min(max(intensity, 0), 1)
            
            generator.impactOccurred(intensity: clampedIntensity)
        }
    }
}
