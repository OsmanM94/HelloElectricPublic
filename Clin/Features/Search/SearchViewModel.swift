//
//  SearchViewModel.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published private(set) var filteredListings: [Listing] = []
    @Published private(set) var searchSuggestions: [String] = []
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let tableName: String = "car_listing"
   
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    init() {
        addSubscribers()
    }
    
    deinit {
        print("DEBUG: SearchViewModel deallocated")
        cancellables.removeAll()
    }
    
    private func addSubscribers() {
        $searchText
            .debounce(for: 0.4, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                Task {
                    await self.searchItems(searchText: searchText)
//                    await self.updateSearchSuggestions(searchText: searchText)
                }
            }
            .store(in: &cancellables)
    }
        
   
    // Network search function
    @MainActor
    func searchItems(searchText: String) async {
        guard !searchText.isEmpty else {
            self.filteredListings = []
            return
        }
        do {
            let searchResults = try await searchItemsFromSupabase(searchText: searchText)
            self.filteredListings = searchResults
        } catch {
            print("DEBUG: Error fetching search results from Supabase: \(error)")
            self.filteredListings = []
        }
    }
    
    // Executes the network search on Supabase
    private func searchItemsFromSupabase(searchText: String) async throws -> [Listing] {
        do {
            let response: [Listing] = try await Supabase.shared.client
                .from(tableName)
                .select()
                .ilike("model, make", pattern: "%\(searchText)%")
                .execute()
                .value
            return response
        } catch {
            print("DEBUG: Failed to fetch listings from Supabase: \(error)")
            throw error
        }
    }
    
//    // Dynamic search suggestions
//    @MainActor
//    private func updateSearchSuggestions(searchText: String) async {
//        guard !searchText.isEmpty else {
//            self.searchSuggestions = []
//            return
//        }
//        
//        do {
//            // Fetching unique suggestions from Supabase
//            let suggestions = try await fetchSearchSuggestions(searchText: searchText)
//            self.searchSuggestions = suggestions
//        } catch {
//            print("DEBUG: Error fetching search suggestions: \(error)")
//            self.searchSuggestions = []
//        }
//    }
//    
//    private func fetchSearchSuggestions(searchText: String) async throws -> [String] {
//        do {
//            let response: [SearchSuggestion] = try await Supabase.shared.client
//                .from(tableName)
//                .select("make, model")
//                .ilike("make", pattern: "%\(searchText)%")
//                .ilike("model", pattern: "%\(searchText)%")
//                .execute()
//                .value
//            
//            // Combine make and model into a list of unique suggestions
//            let suggestions = Set(response.flatMap { [$0.make, $0.model] })
//            return Array(suggestions)
//        } catch {
//            print("DEBUG: Failed to fetch search suggestions from Supabase: \(error)")
//            throw error
//        }
//    }
}

//struct SearchSuggestion: Codable, Hashable {
//    var make: String
//    var model: String
//}
