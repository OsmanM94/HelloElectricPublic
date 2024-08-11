//
//  MarketPlaceViewModel.swift
//  Clin
//
//  Created by asia on 07/08/2024.
//

import Foundation

@Observable
final class MarketViewModel {
    var selectedTab: Int = 0
    var lastSelectedTab: Int = 0
    var isDoubleTap: Bool = false
    
    func handleTabSelection(_ newValue: Int) {
        if newValue == 0 && newValue == lastSelectedTab {
            /// Only toggle isDoubleTap if the current tab is the Listings tab (tag 0)
            isDoubleTap.toggle()
        } else {
            /// Reset the lastSelectedTab when switching to a different tab
            lastSelectedTab = newValue
        }
    }
}
