//
//  StationsViewModel.swift
//  Clin
//
//  Created by asia on 29/08/2024.
//

import Foundation
import MapKit
import Factory

enum ChargerFilter {
    case all, fastCharge, free
}

@Observable
final class EVChargerMapViewModel {
    // MARK: - Misc
    var chargers: [Station] = []
    private let apiKey: String = "310172e1-84a9-433e-b2f6-749b9219b007"
//    private var cache: [String: [Station]] = [:]
   
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.httpDataDownloader) private var httpDownloader
    
    @MainActor
    func fetchChargers(in region: MKCoordinateRegion?) async {
        guard let region = region else {
            print("No valid region provided")
            return
        }
        
        let latitude = region.center.latitude
        let longitude = region.center.longitude
        let radius = min(region.span.latitudeDelta, region.span.longitudeDelta) * 111 // Approx radius in km
        let urlString = "https://api.openchargemap.io/v3/poi/?output=json&latitude=\(latitude)&longitude=\(longitude)&distance=\(radius)&maxresults=5&key=\(apiKey)"
    
        print("Fetching data from network for URL: \(urlString)")
        do {
            let stations: [Station] = try await httpDownloader.fetchData(as: [Station].self, endpoint: urlString)
            self.chargers = stations
            print("Loaded \(stations.count) chargers from network")
           
        } catch {
            print("Error fetching or decoding chargers: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers and misc
     func openInMaps(charger: Station) {
        let placemark = MKPlacemark(coordinate: charger.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = charger.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
