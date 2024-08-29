//
//  StationsViewModel.swift
//  Clin
//
//  Created by asia on 29/08/2024.
//
/// https://openchargemap.org/site/profile/applications
///
import Foundation
import MapKit
import Factory

enum ChargerFilter {
    case all
    case free
    case fast
}

@Observable
final class EVChargerMapViewModel {
    // MARK: - Observable properties
    var chargers: [Station] = []
    private let apiKey: String = "310172e1-84a9-433e-b2f6-749b9219b007"
    private var debounceTask: Task<Void, Never>? = nil
    private let debounceDelay: TimeInterval = 1.0
    var isLoading: Bool = false
    
    // MARK: - Filtered results
    var filteredChargers: [Station] = []
    var selectedFilter: ChargerFilter = .all { didSet { applyFilter() } }
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.httpDataDownloader) private var httpDownloader
    
    @MainActor
    func fetchChargersDebounced(in region: MKCoordinateRegion?) {
        debounceTask?.cancel()
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            await fetchChargers(in: region)
        }
    }
    
  
    // MARK: - Helpers and misc
    
    private func fetchChargers(in region: MKCoordinateRegion?) async {        
        guard let region = region else {
            print("DEBUG: No valid region provided")
            return
        }
        
        let latitude = region.center.latitude
        let longitude = region.center.longitude
        let radius = min(region.span.latitudeDelta, region.span.longitudeDelta) * 111 // Approx radius in km
        
        let urlString = "https://api.openchargemap.io/v3/poi/?output=json&latitude=\(latitude)&longitude=\(longitude)&distance=\(radius)&maxresults=20&key=\(apiKey)"
        
        do {
            let stations: [Station] = try await httpDownloader.fetchData(as: [Station].self, endpoint: urlString)
            
            self.chargers = stations
            applyFilter()
            isLoading = false
            print("DEBUG: Loaded data from network.")
        } catch {
            print("Error loading or decoding chargers: \(error)")
        }
    }
    
    private func applyFilter() {
        switch selectedFilter {
        case .all:
            filteredChargers = chargers
        case .free:
            filteredChargers = chargers.filter { station in
                station.connections.contains { connection in
                    connection.powerKW == 0
                }
            }
        case .fast:
            filteredChargers = chargers.filter { $0.hasFastCharging }
        }
    }
    
    func openInMaps(charger: Station) {
       let placemark = MKPlacemark(coordinate: charger.coordinate)
       let mapItem = MKMapItem(placemark: placemark)
       mapItem.name = charger.name
       mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
   }
    
    // Extract charger, status and connection type informations
    
    func stationSpecs(for charger: Station) -> String? {
        return charger.connections.first?.level?.title
    }
    
    func statusTitle(for charger: Station) -> String? {
        return charger.connections.first?.statusType?.title
    }

    func connectionType(for charger: Station) -> String? {
        return charger.connections.first?.connectionType?.title
    }
    
}


