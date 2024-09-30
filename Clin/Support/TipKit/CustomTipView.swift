//
//  CustomTipView.swift
//  Clin
//
//  Created by asia on 30/09/2024.
//

import SwiftUI
import TipKit

struct CustomTipView<T: Tip>: View {
    let tip: T
    
    var body: some View {
        TipView(tip)
    }
}


