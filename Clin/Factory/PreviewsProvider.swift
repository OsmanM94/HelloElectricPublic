//
//  PropertyWrapper.swift
//  Clin
//
//  Created by asia on 18/08/2024.
//
//
import Factory

class PreviewsProvider {
    static let shared = PreviewsProvider()
    let container = Container.shared
    private init() {}
}
