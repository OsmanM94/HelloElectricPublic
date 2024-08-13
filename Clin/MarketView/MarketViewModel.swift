//
//  MarketPlaceViewModel.swift
//  Clin
//
//  Created by asia on 07/08/2024.
//

import Foundation
import Combine

enum Tab {
    case first
    case second
    case third
}

final class MarketViewModel: ObservableObject {
    @Published var isDoubleTap: Bool = false
    @Published var selectedTab: Tab = .first
    @Published var scrollFirstTabToTop: Bool = false
    
    private var cancellable: AnyCancellable?
    
    init() {
        listenForTabSelection()
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
    
    /// When a new tab is selected, it checks if it matches the currently selected one.
    /// If so, it toggles the appropriate flag (scrollFirstTabToTop or scrollSecondTabToTop) to enable scrolling to the top when the same tab is re-selected.
    private func listenForTabSelection() {
        cancellable = $selectedTab
            .sink { [weak self] newTab in
                guard let self = self else { return }
                if newTab == self.selectedTab {
                    switch newTab {
                    case .first:
                        self.scrollFirstTabToTop.toggle()
                    case .second:
                        break
                    case .third:
                        break
                    }
                }
            }
    }
}
