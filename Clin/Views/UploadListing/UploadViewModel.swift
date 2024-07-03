//
//  UploadViewModel.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation


@Observable
class UploadViewModel {
    var state: ViewState = .loading
    var title: String = ""
    var mileage: Double = 0.0
    var make: String = ""
    var model: String = ""
    var yearOfManufacture: String = ""
    var colour: String = ""
    var price: Double = 0.0
    var isFavourite: Bool = false
    var isPromoted: Bool = false
    
    ///EV Specific
    var batteryCapacity: String = ""
    var range: String = ""
    var publicChargingTime: String = ""
    var homeChargingTime: String = ""
    var warranty: String = ""
    var numberOfOwners: String = ""
    var serviceHistory: String = ""
    var condition: String = ""
    
    ///DVLA checks
    var registrationNumber: String = ""
    var errorMessage: String?
    var isElectric: Bool = false
    
    private let carListingService = CarListingService.shared
    private let dvlaService = DVLAService()
    private let supabase = SupabaseService.shared.client
   
    
    @MainActor
    func createListing() async {
        do {
            guard let user = try? await supabase.auth.session.user else {
                print("No authenticated user found")
                return
            }
            
            try await carListingService.createListing(title: title, userID: user.id)
            print("Listing uploaded succesfully.")
            state = .loaded
        } catch {
            print("Error creating listing: \(error)")
        }
    }
}
