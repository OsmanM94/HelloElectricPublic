//
//  NewsViewModel.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import Foundation
import Factory

@Observable
final class NewsService {
    enum ViewState: Equatable {
        case idle
        case loaded
        case error(String)
    }
    
    var viewState: ViewState = .idle
    var articles = [NewsArticle]()
    
    private(set) var hasMoreArticles: Bool = true
    private(set) var currentPage: Int = 1
    private let pageSize: Int = 20
    
    @ObservationIgnored @Injected(\.httpDataDownloader) private var dataDownloader
    private let apiKey = "35d7a26df33847f39edc3b50756f1a66"
    private let secondKey = "31c85cb62c3841e6b90d49b6977ff8f2"
    
    @MainActor
    func loadNews() async {
        guard hasMoreArticles else { return }
        
        let urlString = "https://newsapi.org/v2/everything?q=Electric+Vehicle+EV&language=en&sortBy=relevancy&pageSize=\(pageSize)&page=\(currentPage)&apiKey=\(secondKey)"
        
        do {
            let newsResponse: NewsResponse = try await dataDownloader.fetchData(as: NewsResponse.self, endpoint: urlString)
            
            if newsResponse.status == "ok" {
                let newArticles = newsResponse.articles
                if newArticles.count < pageSize {
                    hasMoreArticles = false // No more articles to load
                }
                articles.append(contentsOf: newArticles)
                currentPage += 1
                viewState = .loaded
            } else {
                viewState = .error("Failed to load news")
            }
        } catch {
            viewState = .error("Failed to load news: \(error)")
        }
    }

    @MainActor
    func resetState() {
        articles = []
        currentPage = 1
        viewState = .idle
    }
}
