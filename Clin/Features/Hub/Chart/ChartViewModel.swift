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
        case empty(String)
        case error(String)
    }
    
    // MARK: - ViewState
    var viewState: ViewState = .loading
    
    // MARK: - Observable properties
    var yearlyData: [ChartData] = []
    var monthlyData: [ChartData] = []
    var selectedMonth: String = ""
    var selectedYear: String = ""
    
    // MARK: - Dependencies
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabase
    
    // MARK: - Cache
    private let cacheKeyPrefix = "chartDataCacheKey"
    
    // MARK: - Main actor functions
    @MainActor
    func loadChartData() async  {
        viewState = .loading
        
        let cacheKey = "\(cacheKeyPrefix)_year_\(selectedYear)_month_\(selectedMonth)"
            
        let registrationsCache = CacheManager.shared.cache(for: [ChartData].self)
        
        if let cachedData = registrationsCache.get(forKey: cacheKey) {
            processData(cachedData)
            viewState = .loaded
            print("DEBUG: Got data from Cache.")
            return
        }
        
        do {
            let loadedData: [ChartData] = try await supabase.client
                .from("fuel_registrations")
                .select()
                .execute()
                .value
            
            registrationsCache.set(loadedData, forKey: cacheKey)
            processData(loadedData)
            
            viewState = loadedData.isEmpty ? .empty(MessageCenter.MessageType.noAvailableData.message) : .loaded
            print("DEBUG: Got data from API.")
        } catch {
            viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    // MARK: - Helpers
    private func processData(_ data: [ChartData]) {
        let yearly = data.filter { $0.periodType == "year" }
        let monthly = data.filter { $0.periodType == "month" }
        
        yearlyData = yearly
        monthlyData = monthly
        
        selectedYear = yearly.first?.periodLabel ?? "No data found"
        selectedMonth = monthly.first?.periodLabel ?? "No data found"
    }
}

