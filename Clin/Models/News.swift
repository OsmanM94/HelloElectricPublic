//
//  News.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import Foundation

struct Source: Codable, Hashable {
    let id: String?
    let name: String
}

struct NewsArticle: Identifiable, Codable, Hashable {
    let source: Source
    let title: String
    let description: String
    let url: String
    let publishedAt: String
    let content: String
    let urlToImage: String?
    
    var id: String { url }
}

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}
