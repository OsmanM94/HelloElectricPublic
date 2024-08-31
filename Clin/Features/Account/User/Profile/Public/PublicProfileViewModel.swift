//
//  PublicProfileViewModel.swift
//  Clin
//
//  Created by asia on 31/08/2024.
//

import Foundation
import Factory

@Observable
final class PublicProfileViewModel {
    // MARK: - Observable properties
    private(set) var displayName: String = ""
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
        // Attempt to fetch from cache first
        if let cachedProfile = cacheManager.cache(for: Profile.self).get(forKey: sellerID.uuidString) {
            print("DEBUG: Loaded public profile from cache")
            self.profile = cachedProfile
            self.displayName = cachedProfile.username ?? ""
            return
        }
        
        // Fetch from API if not cached
        do {
            print("DEBUG: Fetching public profile from API")
            let profile = try await profileService.loadProfile(for: sellerID)
            self.profile = profile
            self.displayName = profile.username ?? ""
            
            // Cache the profile
            cacheManager.cache(for: Profile.self).set(profile, forKey: sellerID.uuidString)
        } catch {
            debugPrint(error)
            print("DEBUG: Unable to get public profile")
        }
    }
}
