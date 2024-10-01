//
//  ProhibitedWordsService.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import Foundation

final class ProhibitedWordsService: ProhibitedWordsServiceProtocol {
   
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
    
    func containsProhibitedWords(in texts: [String]) -> Bool {
        for text in texts {
            if containsProhibitedWord(text) {
                return true
            }
        }
        return false
    }
    
    func containsProhibitedWordsDictionary(in fields: [String: String]) -> [String: Bool] {
           var results: [String: Bool] = [:]
           for (fieldName, fieldValue) in fields {
               results[fieldName] = containsProhibitedWord(fieldValue)
           }
           return results
       }
}
