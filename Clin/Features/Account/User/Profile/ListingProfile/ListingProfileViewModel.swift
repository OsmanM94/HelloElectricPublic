//
//  PublicProfileViewModel.swift
//  Clin
//
//  Created by asia on 31/08/2024.
//

import Foundation
import Factory

@Observable
final class ListingProfileViewModel {
    // MARK: - Observable properties
    private(set) var displayName: String = "Private Seller"
    private(set) var address: String = ""
    private(set) var postcode: String = ""
    private(set) var location: String = ""
    private(set) var website: String = ""
    private(set) var companyNumber: String = ""
    private(set) var profile: Profile? = nil

    var sellerID: UUID?
   
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.profileService) private var profileService
    private let cacheManager = CacheManager.shared
    
    init(sellerID: UUID) {
        self.sellerID = sellerID
        print("DEBUG: Did init Public profile vm")
        Task {
            await loadPublicProfile(for: sellerID)
        }
    }
    
    // MARK: - Main actor functions
    @MainActor
    func loadPublicProfile(for sellerID: UUID) async {
        // Attempt to load from cache first
        if let cachedProfile = cacheManager.cache(for: Profile.self).get(forKey: sellerID.uuidString) {
            print("DEBUG: Loaded public profile from cache")
            self.profile = cachedProfile
            self.displayName = cachedProfile.username ?? ""
            self.address = cachedProfile.address ?? ""
            self.postcode = cachedProfile.postcode ?? ""
            self.location = cachedProfile.location ?? ""
            self.website = cachedProfile.website ?? ""
            self.companyNumber = cachedProfile.companyNumber ?? ""
            return
        }
        
        // Load from API if not cached
        do {
            print("DEBUG: Loading public profile from API")
            let profile = try await profileService.loadProfile(for: sellerID)
            self.profile = profile
            self.displayName = profile.username ?? ""
            self.address = profile.address ?? ""
            self.postcode = profile.postcode ?? ""
            self.location = profile.location ?? ""
            self.website = profile.website ?? ""
            self.companyNumber = profile.companyNumber ?? ""
            
            // Cache the profile
            cacheManager.cache(for: Profile.self).set(profile, forKey: sellerID.uuidString)
        } catch {
            debugPrint(error)
            print("DEBUG: Unable to get public profile")
        }
    }
}
