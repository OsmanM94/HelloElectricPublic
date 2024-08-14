//
//  SearchViewModel.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case loaded
    }
    
    @Published private(set) var filteredListings: [Listing] = []
    @Published private(set) var searchSuggestions: [String] = []
    @Published var searchText: String = ""
    @Published var viewState: ViewState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
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
            .debounce(for: .seconds(1.5) , scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                self.viewState = .loading
           
                if let searchTask = self.searchTask {
                    print("DEBUG: Cancelling previous task")
                    searchTask.cancel()
                }
                
                self.searchTask = Task {
                    print("DEBUG: Starting new search task for text: \(searchText)")
                    await self.searchItems(searchText: searchText)
                }
            }
            .store(in: &cancellables)
    }
        
   
    // Network search function
    @MainActor
    func searchItems(searchText: String) async {
        guard !searchText.isEmpty else {
            print("DEBUG: Search text is empty, clearing filtered listings")
            self.filteredListings = []
            self.viewState = .loaded
            return
        }
        
        self.viewState = .loading
        defer {
            if self.viewState == .loading {
                self.viewState = .loaded
            }
        }
        
        do {
            let searchResults = try await searchItemsFromSupabase(searchText: searchText)
            print("DEBUG: Search completed successfully for text: \(searchText)")
            self.filteredListings = searchResults
        } catch {
            print("DEBUG: Error fetching search results from Supabase: \(error)")
            self.filteredListings = []
        }
    }
    
    // Executes the network search on Supabase
    private func searchItemsFromSupabase(searchText: String) async throws -> [Listing] {
        // Check for task cancellation
        if Task.isCancelled {
            print("DEBUG: Task was cancelled before starting the search")
            return []
        }
        do {
            let response: [Listing] = try await Supabase.shared.client
                .from(tableName)
                .select()
                .ilike("model, make", pattern: "%\(searchText)%")
                .execute()
                .value
            
            if Task.isCancelled {
                print("DEBUG: Task was cancelled after fetching the results")
                return []
            }
            
            print("DEBUG: Fetched \(response.count) listings from Supabase for text: \(searchText)")
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
