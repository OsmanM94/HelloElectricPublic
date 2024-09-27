//
//  NewsViewModel.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import Foundation
import Factory

/// API: https://newsapi.org

@Observable
final class NewsViewModel {
    // MARK: - Enum
    enum ViewState: Equatable {
        case idle
        case loaded
        case error(String)
    }
    
    // MARK: - Observable properties
    var viewState: ViewState = .idle
    var articles = [NewsArticle]()
    
    // MARK: - Pagination
    private(set) var hasMoreArticles: Bool = true
    private(set) var currentPage: Int = 1
    private let pageSize: Int = 25
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.httpClient) private var httpClient
    private let apiKey = "35d7a26df33847f39edc3b50756f1a66"
    private let secondKey = "31c85cb62c3841e6b90d49b6977ff8f2"
    
    // MARK: - Cache
    private let cacheKeyPrefix = "newsArticlesCacheKey"
    private var articlesCache: GenericCache<[NewsArticle]> {
        CacheManager.shared.cache(for: [NewsArticle].self)
    }
    
    // MARK: - Main actor functions
    @MainActor
    func loadNews() async {
        guard hasMoreArticles else { return }
        
        let cacheKey = "\(cacheKeyPrefix)_page_\(currentPage)"
        
        if let cachedArticles = articlesCache.get(forKey: cacheKey) {
            articles.append(contentsOf: cachedArticles)
            currentPage += 1
            viewState = .loaded
            print("DEBUG: Got articles from Cache for page \(currentPage - 1)")
            return
        }
        
        let urlString = "https://newsapi.org/v2/everything?q=Electric+Vehicle+EV&language=en&sortBy=relevancy&pageSize=\(pageSize)&page=\(currentPage)&apiKey=\(secondKey)"
        
        do {
            let newsResponse: NewsResponse = try await httpClient.loadData(as: NewsResponse.self, endpoint: urlString, headers: nil)
            
            if newsResponse.status == "ok" {
                let newArticles = newsResponse.articles
                if newArticles.count < pageSize {
                    hasMoreArticles = false
                }
                articles.append(contentsOf: newArticles)
                articlesCache.set(newArticles, forKey: cacheKey)
                currentPage += 1
                viewState = .loaded
                print("DEBUG: Got articles from API for page \(currentPage - 1)")
            } else {
                viewState = .error(MessageCenter.MessageType.failedToLoadNews.message)
            }
        } catch {
            viewState = .error(MessageCenter.MessageType.failedToLoadNews.message)
        }
    }
    
    @MainActor
    func resetState() {
        viewState = .loaded
    }
    
    private func clearCache() {
        for page in 1...currentPage {
            let cacheKey = "\(cacheKeyPrefix)_page_\(page)"
            articlesCache.set([], forKey: cacheKey)  // Setting an empty array clears the cache
        }
    }
}
