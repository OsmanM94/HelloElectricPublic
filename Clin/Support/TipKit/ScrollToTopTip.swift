//
//  SellerLocationTip.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import Foundation
import TipKit

struct ScrollToTopTip: Tip {
    var title: Text {
        Text("Shake to Scroll to Top")
    }
    
    var message: Text? {
        Text("Shake your device to quickly scroll back to the top of the list.")
    }
    
    var image: Image? {
        Image(systemName: "iphone.gen3.radiowaves.left.and.right")
    }
}
