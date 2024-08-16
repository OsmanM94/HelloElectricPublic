//
//  HideKeyboard.swift
//  Clin
//
//  Created by asia on 14/08/2024.
//

import SwiftUI

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
