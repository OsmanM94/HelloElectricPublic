//
//  DelayedAction.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//
import SwiftUI

func performAfterDelay(_ delay: TimeInterval, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        action()
    }
}
