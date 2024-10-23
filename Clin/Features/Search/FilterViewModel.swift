

import Foundation

@Observable
final class SearchFilters {
    var make: String = "Any" { didSet { updateFilterState() } }
    var model: String = "Any" { didSet { updateFilterState() } }
    var location: String = "Any" { didSet { updateFilterState() } }
    var body: String = "Any" { didSet { updateFilterState() } }
    var selectedYear: String = "Any" { didSet { updateFilterState() } }
    var maxPrice: Double = 100_000 { didSet { updateFilterState() } }
    var condition: String = "Any" { didSet { updateFilterState() } }
    var maxMileage: Double = 300_000 { didSet { updateFilterState() } }
    var colour: String = "Any" { didSet { updateFilterState() } }
    var maxPublicChargingTime: String = "Any" { didSet { updateFilterState() } }
    var maxHomeChargingTime: String = "Any" { didSet { updateFilterState() } }
    var batteryCapacity: String = "Any" { didSet { updateFilterState() } }
    var regenBraking: String = "Any" { didSet { updateFilterState() } }
    var warranty: String = "Any" { didSet { updateFilterState() } }
    var serviceHistory: String = "Any" { didSet { updateFilterState() } }
    var numberOfOwners: String = "Any" { didSet { updateFilterState() } }
    
    var powerBhp: Int = 1000 {
        didSet {
            // Ensure BHP stays within bounds
            if powerBhp > maxAllowedBHP {
                powerBhp = maxAllowedBHP
            }
            if powerBhp < minAllowedBHP {
                powerBhp = minAllowedBHP
            }
            updateFilterState()
        }
    }
    
    var range: Int = 1000 {
        didSet {
            // Ensure range stays within bounds
            if range > maxAllowedRange {
                range = maxAllowedRange
            }
            if range < minAllowedRange {
                range = minAllowedRange
            }
            updateFilterState()
        }
    }
    
    private let maxAllowedRange = 1000 // 4 digits max
    private let minAllowedRange = 0
    private let maxAllowedBHP = 1000 // 4 digits max
    private let minAllowedBHP = 0
    
    private(set) var isFilterApplied: Bool = false
    
    func updateModel(_ newModel: String) {
        self.model = newModel
        updateFilterState()
    }
    
    func reset() {
        make = "Any"
        model = "Any"
        body = "Any"
        location = "Any"
        selectedYear = "Any"
        maxPrice = 100_000
        condition = "Any"
        maxMileage = 300_000
        range = 1000
        colour = "Any"
        maxPublicChargingTime = "Any"
        maxHomeChargingTime = "Any"
        batteryCapacity = "Any"
        powerBhp = 1000
        regenBraking = "Any"
        warranty = "Any"
        serviceHistory = "Any"
        numberOfOwners = "Any"
    }
    
    private func updateFilterState() {
        isFilterApplied = isAnyFilterActive()
    }
    
    private func isAnyFilterActive() -> Bool {
        return make != "Any" ||
        model != "Any" ||
        body != "Any" ||
        location != "Any" ||
        selectedYear != "Any" ||
        maxPrice < 100_000 ||
        condition != "Any" ||
        maxMileage < 300_000 ||
        range < 1000 ||
        colour != "Any" ||
        maxPublicChargingTime != "Any" ||
        maxHomeChargingTime != "Any" ||
        batteryCapacity != "Any" ||
        powerBhp < 1000 ||
        regenBraking != "Any" ||
        warranty != "Any" ||
        serviceHistory != "Any" ||
        numberOfOwners != "Any"
    }
}
