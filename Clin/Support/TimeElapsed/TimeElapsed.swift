//
//  TimeElapsed.swift
//  Clin
//
//  Created by asia on 24/07/2024.
//

import Foundation

func timeElapsedString(since date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: date, relativeTo: Date())
}
