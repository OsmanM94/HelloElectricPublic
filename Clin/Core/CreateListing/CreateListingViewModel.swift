//
//  UploadViewModel.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation


@Observable
final class CreateListingViewModel {
    enum CreateListingViewState {
        case idle
        case loading
        case loaded
        case success(String)
        case error(String)
    }
    
    var viewState: CreateListingViewState = .loaded
    
    var make: String = ""
    var model: String = ""
    var mileage: Double = 0.0
    var yearOfManufacture: String = ""
    var price: Double = 0.0
    var description: String = ""
    var range: String = ""
    var isPromoted: Bool = false
    
    ///EV Specific
    var publicChargingTime: String = ""
    var homeChargingTime: String = ""
    var warranty: String = ""
    var numberOfOwners: String = ""
    var serviceHistory: String = ""
    var condition: String = ""
    var colour: String = ""
    
    ///DVLA checks
    var registrationNumber: String = ""
    
    private let carListingService = DatabaseService.shared
    private let dvlaService = DvlaService()
    private let supabase = SupabaseService.shared.client
    
    let yearsOfmanufacture: [String] = Array(2010...2030).map { String($0) }
    
    @MainActor
    func createListing() async {
        viewState = .loading
        do {
            guard let user = try? await supabase.auth.session.user else {
                print("No authenticated user found")
                return
            }
            
            try await carListingService.createListing(make: make, userID: user.id)
            viewState = .success("Listing created successfully.")
        } catch {
            self.viewState = .error("Error creating listing.")
            print(error)
        }
    }
    
    @MainActor
    func sendRequest() async {
        viewState = .loading
        do {
            let decodedCar = try await dvlaService.fetchCarDetails(registrationNumber: registrationNumber)
            
            if decodedCar.fuelType.uppercased() == "ELECTRICITY" {
                self.make = decodedCar.make
                self.yearOfManufacture = "\(decodedCar.yearOfManufacture)"
                viewState = .loaded
            } else {
                self.viewState = .error("Your vehicle is not electric.")
            }
        } catch {
            self.viewState = .error("Invalid registration number.")
            print(error)
        }
    }
    
    func resetState() {
        registrationNumber = ""
        make = ""
        model = ""
        yearOfManufacture = ""
        colour = ""
        price = 0
        mileage = 0
        numberOfOwners = ""
        viewState = .idle
    }
}
