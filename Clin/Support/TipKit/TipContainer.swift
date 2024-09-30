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
        Text("Shake to scroll to top")
    }
    
    var message: Text? {
        Text("Shake your device to quickly scroll back to the top of the list.")
    }
    
    var image: Image? {
        Image(systemName: "iphone.gen3.radiowaves.left.and.right")
    }
}

struct RefreshListingTip: Tip {
    var title: Text {
        Text("Refresh your listing")
    }
    
    var message: Text? {
        Text("Tap to refresh this listing and move it to the top of the list..")
    }
    
    var image: Image? {
        Image(systemName: "arrow.clockwise")
    }
}

struct DragDropImageTip: Tip {
    var title: Text {
        Text("Rearrange Your Images")
    }
    
    var message: Text? {
        Text("You can drag and drop images to reorder them.")
    }
    
    var image: Image? {
        Image(systemName: "hand.draw")
    }
}
