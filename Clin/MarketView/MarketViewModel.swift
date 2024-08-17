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
    case fourth
}

final class MarketViewModel: ObservableObject {
    @Published var selectedTab: Tab = .first
    @Published var scrollFirstTabToTop: Bool = false
    
    private var cancellable: AnyCancellable?
    
    init() {
        listenForTabSelection()
        DispatchQueue.main.async {
            self.scrollToTopIfNeeded()
        }
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
        
    private func listenForTabSelection() {
        cancellable = $selectedTab
            .sink { [weak self] newTab in
                guard let self = self else { return }
                if newTab == self.selectedTab {
                    self.scrollToTopIfNeeded()
                }
            }
    }
    
    private func scrollToTopIfNeeded() {
        switch selectedTab {
        case .first:
            self.scrollFirstTabToTop.toggle()
        case .second, .third, .fourth:
            break
        }
    }
}
