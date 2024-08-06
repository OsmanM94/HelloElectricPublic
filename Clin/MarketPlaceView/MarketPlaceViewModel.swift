//
//  MarketPlaceViewModel.swift
//  Clin
//
//  Created by asia on 07/08/2024.
//

import Foundation

@Observable
final class MarketPlaceViewModel {
    var selectedTab: Int = 0
    var lastSelectedTab: Int = 0
    var isDoubleTap: Bool = false
    
    func handleTabSelection(_ newValue: Int) {
        if newValue == lastSelectedTab {
            isDoubleTap.toggle()
        } else {
            lastSelectedTab = newValue
        }
    }
}
