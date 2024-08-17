//
//  PreviewHelpers.swift
//  Clin
//
//  Created by asia on 17/08/2024.
//

import Foundation

struct PreviewHelpers {
    
    static func makeMockListingService() -> MockListingService {
        return MockListingService()
    }
    
    static func makeMockFavouriteService() -> MockFavouriteService {
        return MockFavouriteService()
    }

    static func makeMockImageManager() -> MockImageManager {
        return MockImageManager(isHeicSupported: true)
    }

    static func makeMockProhibitedWordsService() -> MockProhibitedWordsService {
        return MockProhibitedWordsService(prohibitedWords: [""])
    }

    static func makeMockHttpDataDownloader() -> MockHTTPDataDownloader {
        return MockHTTPDataDownloader()
    }

    static func makeMockDvlaService() -> MockDvlaService {
        return MockDvlaService()
    }

    static func makeMockFavouriteViewModel() -> FavouriteViewModel {
        return FavouriteViewModel(favouriteService: MockFavouriteService())
    }

    static func makePreviewListingViewModel() -> ListingViewModel {
        return ListingViewModel(listingService: makeMockListingService())
    }

    static func makePreviewCreateFormViewModel() -> CreateFormViewModel {
        return CreateFormViewModel(
            listingService: makeMockListingService(),
            imageManager: makeMockImageManager(),
            prohibitedWordsService: makeMockProhibitedWordsService(),
            httpDataDownloader: makeMockHttpDataDownloader(),
            dvlaService: makeMockDvlaService()
        )
    }
    
    static func makePreviewEditFormViewModel() -> EditFormViewModel {
        return EditFormViewModel(
            listingService: makeMockListingService(),
            imageManager: makeMockImageManager(),
            prohibitedWordsService: makeMockProhibitedWordsService(),
            httpDownloader: makeMockHttpDataDownloader()
        )
    }
}
