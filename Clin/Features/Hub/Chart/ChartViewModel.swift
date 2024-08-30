//
//  ChartViewModel.swift
//  Clin
//
//  Created by asia on 30/08/2024.
//

import Foundation
import Factory

@Observable
final class ChartViewModel {
    // MARK: - Enum
    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - ViewState
    var viewState: ViewState = .loading
    
    // MARK: - Observable properties
    var yearlyData: [Registrations] = []
    var monthlyData: [Registrations] = []
    var selectedMonth: String = ""
    var selectedYear: String = ""
    
    // MARK: - Dependencies
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabase
    
    // MARK: - Cache
    private let cacheKeyPrefix = "chartDataCacheKey"
    
    // MARK: - Main actor functions
    @MainActor
    func loadChartData() async throws {
        let cacheKey = "\(cacheKeyPrefix)_year_\(selectedYear)_month_\(selectedMonth)"
            
        let registrationsCache = CacheManager.shared.cache(for: [Registrations].self)
        
        if let cachedData = registrationsCache.get(forKey: cacheKey) {
            processData(cachedData)
            viewState = .loaded
            print("DEBUG: Got data from Cache.")
            return
        }
        
        do {
            // Fetch data from the API
            let loadedData: [Registrations] = try await supabase.client
                .from("fuel_registrations")
                .select()
                .execute()
                .value
            
            registrationsCache.set(loadedData, forKey: cacheKey)
            processData(loadedData)
            viewState = .loaded
            print("DEBUG: Got data from API.")
        } catch {
            // Handle error state
            viewState = .error("Error loading chart data.")
            print("DEBUG: Error loading chart data: \(error)")
        }
    }
    
    // MARK: - Helpers
    private func processData(_ data: [Registrations]) {
        // Split data into yearly and monthly based on the 'month_year' column
        let yearly = data.filter { $0.periodType == "year" }
        let monthly = data.filter { $0.periodType == "month" }
        
        // Update properties with the loaded data
        yearlyData = yearly
        monthlyData = monthly
        
        // Update selectedMonth and selectedYear
        selectedYear = yearly.first?.periodLabel ?? "No data found"
        selectedMonth = monthly.first?.periodLabel ?? "No data found"
    }
}

