//
//  FaceID.swift
//  Clin
//
//  Created by asia on 19/09/2024.
//

import Foundation
import LocalAuthentication


@Observable
final class FaceID {
    
    enum ViewState: Equatable {
        case idle
        case loading
        case authenticated
        case error(String)
    }
    
    private var context: LAContext?
    var viewState: ViewState = .idle
    
    @MainActor
    var isBiometricsAvailable: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    @MainActor
    func authenticate() async {
        viewState = .loading
        
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            viewState = .error(MessageCenter.MessageType.biometricsNotAvailable.message)
            return
        }
        
        self.context = context
        
        do {
            let reason = "We need to unlock your data."
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            if success {
                viewState = .authenticated
            } else {
                viewState = .error(MessageCenter.MessageType.authenticationFailed.message)
            }
        } catch {
            viewState = .error(MessageCenter.MessageType.authenticationFailed.message)
        }
    }
    
    @MainActor
    func cancelAuthentication() {
        context?.invalidate()
        viewState = .idle
    }
}
