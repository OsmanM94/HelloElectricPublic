//
//  JSONLoadingError.swift
//  Clin
//
//  Created by asia on 05/07/2024.
//

import Foundation

enum JSONLoadingError: Error {
    case fileNotFound(String)
    case dataLoadingError(Error)
    case dataParsingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .fileNotFound(let filename):
            return "Couldn't find \(filename) in main bundle."
        case .dataLoadingError(let error):
            return "Couldn't load data from file:\n\(error)"
        case .dataParsingError(let error):
            return "Couldn't parse data:\n\(error)"
        }
    }
}
