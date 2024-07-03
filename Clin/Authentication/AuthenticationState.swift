//
//  AuthenticationState.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import Foundation

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case register
}
