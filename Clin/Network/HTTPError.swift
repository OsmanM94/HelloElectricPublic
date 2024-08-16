//
//  ApiError.swift
//  Clin
//
//  Created by asia on 16/08/2024.
//

import Foundation

enum HTTPError: Error {
    case requestFailed(description: String)
    case invalidStatusCode(statuscode: Int)
    case decodingError(error: Error)
    case encodingError(error: Error)
    
    var customDescription: String {
        switch self {
        case .requestFailed(let description):
            return "Request failed: \(description)"
        case .invalidStatusCode(let statuscode):
            return "Invalid status code \(statuscode)"
        case .decodingError(let error):
            return "Decoding error \(error)"
        case .encodingError(error: let error):
            return "Encoding error \(error)"
        }
    }
}
