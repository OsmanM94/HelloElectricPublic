//
//  ProfileViewState.swift
//  Clin
//
//  Created by asia on 05/07/2024.
//

import Foundation

enum ProfileViewState {
        case idle
        case loading
        case error(String)
        case success(String)
        
        var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }
        
        var errorMessage: String? {
            if case .error(let message) = self {
                return message
            }
            return nil
        }
        
        var isLoaded: String? {
            if case .success(let message) = self {
                return message
            }
            return nil
        }
    }
