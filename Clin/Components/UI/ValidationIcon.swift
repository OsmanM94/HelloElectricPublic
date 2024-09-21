//
//  ValidationOverlay.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import SwiftUI

@ViewBuilder
func validationIcon(isValid: Bool) -> some View {
    Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
        .foregroundStyle(isValid ? .accent : .gray)
        .contentTransition(.symbolEffect(.replace))
}

