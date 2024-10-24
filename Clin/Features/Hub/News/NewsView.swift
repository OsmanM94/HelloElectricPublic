//
//  News.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import SwiftUI

struct NewsView: View {
    @State private var viewModel = NewsViewModel()
    @State private var shouldScrollToTop: Bool = false
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .idle:
                CustomProgressView(message: "Loading...")
                
            case .loaded:
                newsList
                
            case .error(let message):
                ErrorView(message: message,
                          refreshMessage: "Try again",
                          retryAction: {
                    viewModel.resetState()
                }, systemImage: "xmark.circle.fill")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.loadNews()
            }
        }
        .onShake {
            shouldScrollToTop.toggle()
        }
    }
    
    private var newsList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.articles, id: \.id) { article in
                    NavigationLink(destination: NewsDetailView(article: article)) {
                        NewsCell(article: article)
                            .id(article.id)
                    }
                    .task {
                        if article == viewModel.articles.last {
                            await viewModel.loadNews()
                        }
                    }
                }
                .listRowSeparator(.hidden, edges: .all)
                
                if viewModel.hasMoreArticles {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                        .id(UUID())
                        .listRowSeparator(.hidden, edges: .all)
                }
            }
            .listStyle(.plain)
            .refreshable {}
            .onChange(of: shouldScrollToTop) { _, newValue in
                if newValue, let firstArticleId = viewModel.articles.first?.id {
                    withAnimation {
                        proxy.scrollTo(firstArticleId, anchor: .top)
                    }
                    shouldScrollToTop = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shouldScrollToTop.toggle()
                    } label: {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .tint(.primary)
                    }
                    .disabled(viewModel.viewState == .idle)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewsView()
    }
}
