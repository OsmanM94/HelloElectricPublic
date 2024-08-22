//
//  FactoryContainer.swift
//  Clin
//
//  Created by asia on 18/08/2024.
//

import Factory

//MARK: Dependencies registration
extension Container {
    /// Database
    var supabaseService: Factory<SupabaseProtocol> {
        Factory(self) { SupabaseService.createDefault() }.singleton
    }
    
    /// Managers
    var imageManager: Factory<ImageManagerProtocol> {
        Factory(self) { ImageManager() }
    }
    
    /// Services
    var httpDataDownloader: Factory<HTTPDataDownloaderProtocol> {
        Factory(self) { HTTPDataDownloader() }
    }
    
    var prohibitedWordsService: Factory<ProhibitedWordsServiceProtocol> {
        Factory(self) { ProhibitedWordsService() }
    }
    
    var dvlaService: Factory<DvlaServiceProtocol> {
        Factory(self) { DvlaService() }
    }
    
    var listingService: Factory<ListingServiceProtocol> {
        Factory(self) { ListingService() }.singleton
    }
    
    var favouriteService: Factory<FavouriteServiceProtocol> {
        Factory(self) { FavouriteService() }
    }
    
    var databaseService: Factory<DatabaseServiceProtocol> {
        Factory(self) { DatabaseService() }
    }
    
    var profileService: Factory<ProfileServiceProtocol> {
        Factory(self) { ProfileService() }
    }
    
    var searchService: Factory<SearchServiceProtocol> {
        Factory(self) { SearchService() }
    }
}
