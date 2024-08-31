//
//  EnvironmentKeys.swift
//  Clin
//
//  Created by asia on 31/08/2024.
//

import SwiftUI

// Define an Environment Key for ProfileViewModel
private struct ProfileViewModelKey: EnvironmentKey {
    static let defaultValue: PrivateProfileViewModel = PrivateProfileViewModel() // Default can be a placeholder or a current user model
}

extension EnvironmentValues {
    var profileViewModel: PrivateProfileViewModel {
        get { self[ProfileViewModelKey.self] }
        set { self[ProfileViewModelKey.self] = newValue }
    }
}
