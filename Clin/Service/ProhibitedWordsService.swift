//
//  ProhibitedWordsService.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import Foundation


final class ProhibitedWordsService: ProhibitedWordsServiceProtocol {
    
    init() {
        print("DEBUG: Did init prohibited words service")
    }
   
    private(set) var prohibitedWords: Set<String> = []
    
    func loadProhibitedWords() async throws {
        do {
            let words: [String] = try await loadAsync("prohibited_words.json")
            self.prohibitedWords = Set(words)
        } catch {
            throw error
        }
    }
    
    func containsProhibitedWord(_ text: String) -> Bool {
        let words = text.lowercased().split(separator: " ")
        return words.contains { prohibitedWords.contains(String($0)) }
    }    
    
    func containsProhibitedWords(in fields: [String]) -> Bool {
        for field in fields {
            if containsProhibitedWord(field) {
                return true
            }
        }
        return false
    }
}
