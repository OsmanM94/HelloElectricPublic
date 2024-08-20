//
//  SearchViewModel.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import Foundation
import Factory

@Observable
final class SearchViewModel {
    enum ViewState {
        case idle
        case loading
        case loaded
    }
    
    var searchText: String = ""
    var viewState: ViewState = .idle
    
    private(set) var filteredListings: [Listing] = []
    private(set) var searchSuggestions: [String] = []
   
    private let tableName: String = "car_listing"
    
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabaseService
  
    init() {
        print("DEBUG: Did init search viewmodel")
    }
    
    @MainActor
    func resetState() {
        self.searchText = ""
        self.filteredListings.removeAll()
        viewState = .idle
    }
    
    @MainActor
    func searchItems() async {
        guard !searchText.isEmpty else { return }
        self.viewState = .loading
        
        do {
            let searchResults = try await searchItemsFromSupabase(searchText: searchText)
            print("DEBUG: Search completed successfully for text: \(searchText)")
            self.filteredListings = searchResults
            self.viewState = .loaded
        } catch {
            print("DEBUG: Error fetching search results from Supabase: \(error)")
            self.filteredListings = []
        }
    }
    
    private func searchItemsFromSupabase(searchText: String) async throws -> [Listing] {
        do {
            let response: [Listing] = try await supabaseService.client
                .from(tableName)
                .select()
//                .ilike("make", pattern: "%\(searchText)%")
                .or("make.ilike.%\(searchText)%,model.ilike.%\(searchText)%")
                .execute()
                .value
            
            print("DEBUG: Fetched \(response.count) listings from Supabase for text: \(searchText)")
            return response
        } catch {
            print("DEBUG: Failed to fetch listings from Supabase: \(error)")
            throw error
        }
    }
}

