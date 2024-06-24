//
//  ContentView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct RouterView: View {
    
    @Environment(AuthViewModel.self) private var viewModel
    
    var body: some View {
        Group {
            if viewModel.authenticationState == .authenticated {
                SettingsView()
            } else {
                AuthenticationView()
            }
        }
    }
}

#Preview {
    RouterView()
        .environment(AuthViewModel())
}
