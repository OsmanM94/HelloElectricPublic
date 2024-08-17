//
//  MockProhibitedWordsService.swift
//  Clin
//
//  Created by asia on 17/08/2024.
//

import Foundation

struct MockProhibitedWordsService: ProhibitedWordsServiceProtocol {
    var prohibitedWords: Set<String>
    
    func loadProhibitedWords() async throws {
        
    }
    
    func containsProhibitedWord(_ text: String) -> Bool {
        return true
    }
    
    func containsProhibitedWords(in fields: [String]) -> Bool {
        return true
    }
    
    // Implement the required methods with mock behavior
}
