//
//  JSONDecoder.swift
//  Clin
//
//  Created by asia on 04/07/2024.
//

import Foundation

func loadAsync<T: Decodable>(_ filename: String) async throws -> T {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        throw JSONLoadingError.fileNotFound(filename)
    }
    do {
        let data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
        
    } catch let error as DecodingError {
        throw JSONLoadingError.dataParsingError(error)
        
    } catch {
        throw JSONLoadingError.dataLoadingError(error)
    }
}
