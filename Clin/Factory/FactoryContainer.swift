//
//  FactoryContainer.swift
//  Clin
//
//  Created by asia on 18/08/2024.
//

import Factory

//MARK: Dependency registration
extension Container {
    /// Database
    var supabaseService: Factory<SupabaseProtocol> {
        Factory(self) { SupabaseService.createDefault() }.singleton
    }
    
    /// Managers
    var imageManager: Factory<ImageManagerProtocol> {
        Factory(self) { ImageManager() }
    }
    
    var locationManager: Factory<LocationManager> {
        Factory(self) { LocationManager() }
    }
    
    /// Services
    var httpClient: Factory<httpClientProtocol> {
        Factory(self) { HTTPClient() }
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
    
    var companiesHouse: Factory<CompaniesHouseServiceProtocol> {
        Factory(self) { CompaniesHouseService() }
    }
    
    var evDatabase: Factory<EVDatabaseServiceProtocol> {
        Factory(self) { EVDatabaseService() }
    }
    
    var authService: Factory<AuthServiceProtocol> {
        Factory(self) { AuthenticationService() }
    }
        
    /// ViewModels
    var createFormDataModel: Factory<CreateFormDataModel> {
        Factory(self) { CreateFormDataModel() }
    }
    
    var createFormImageManager: Factory<CreateFormImageManager> {
        Factory(self) { CreateFormImageManager() }
    }
    
    var createFormDataLoader: Factory<CreateFormDataLoader> {
        Factory(self) { CreateFormDataLoader() }
    }
    
    var editFormImageManager: Factory<EditFormImageManager> {
        Factory(self) { EditFormImageManager() }
    }
    
    var editFormDataLoader: Factory<EditFormDataLoader> {
        Factory(self) { EditFormDataLoader() }
    }
    
    var searchDataLoader: Factory<SearchDataLoader> {
        Factory(self) { SearchDataLoader() }
    }
    
    var searchFilters: Factory<SearchFilters> {
        Factory(self) { SearchFilters() }
    }
    
    var searchLogic: Factory<SearchLogic> {
        Factory(self) { SearchLogic() }
    }
    
    var faceID: Factory<FaceID> {
        Factory(self) { FaceID() }
    }
 }
