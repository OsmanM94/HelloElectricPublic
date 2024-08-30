//
//  StationsViewModel.swift
//  Clin
//
//  Created by asia on 29/08/2024.
//
/// API : https://openchargemap.org/site/profile/applications
///
import Foundation
import MapKit
import Factory

enum StationFilter {
    case all
    case free
    case fast
}

@Observable
final class StationViewModel {
    // MARK: - Observable properties
    var stations: [Station] = []
    var isLoading: Bool = false
    var selectedStation: Station?
    
    private let apiKey: String = "310172e1-84a9-433e-b2f6-749b9219b007"
   
    // MARK: - Filtered results
    var filteredStations: [Station] = []
    var selectedFilter: StationFilter = .all { didSet { applyFilter() } }
    
    // MARK: - Debounce properties
    private var debounceTask: Task<Void, Never>? = nil
    private let debounceDelay: TimeInterval = 0.5
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.httpDataDownloader) private var httpDownloader
    
    // MARK: - Main actor functions
    @MainActor
    func loadStationsDebounced(in region: MKCoordinateRegion?) {
        debounceTask?.cancel()
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            await loadStations(in: region)
        }
    }
    
    // MARK: - Helpers and misc
    
     private func loadStations(in region: MKCoordinateRegion?) async {
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
                        
            self.stations = stations
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
            filteredStations = stations
        case .free:
            filteredStations = stations.filter { station in
                station.connections.contains { connection in
                    connection.powerKW == 0
                }
            }
        case .fast:
            filteredStations = stations.filter { $0.hasFastCharging }
        }
    }
    
    func openInMaps(station: Station) {
       let placemark = MKPlacemark(coordinate: station.coordinate)
       let mapItem = MKMapItem(placemark: placemark)
       mapItem.name = station.name
       mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
   }
    
    // Extract station, status and connection type informations
    
    func stationSpecs(for station: Station) -> String? {
        return station.connections.first?.level?.title
    }
    
    func stationStatus(for station: Station) -> String? {
        return station.connections.first?.statusType?.title
    }

    func connectionType(for station: Station) -> String? {
        return station.connections.first?.connectionType?.title
    }
}


