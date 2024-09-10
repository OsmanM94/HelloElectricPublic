//
//  SellerLocationTip.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import Foundation
import TipKit

struct SellerLocationTip: Tip {
    var title: Text {
        Text("About the Location")
    }
    
    var message: Text? {
        Text("The location shown represents the general area where the seller is based, not their exact address. This helps protect the seller's privacy while giving you a good idea of the item's location.")
    }
    
    var image: Image? {
        Image(systemName: "mappin.and.ellipse")
    }
}
