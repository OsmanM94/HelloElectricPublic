//
//  EVDataListView.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import SwiftUI

struct EVListView: View {
    @State private var viewModel = EVDataViewModel()
    
    @State private var showInfoSheet: Bool = false
    @FocusState private var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .loading:
                    CustomProgressView()
                    
                case .loaded:
                    searchBar
                    listContent
                    
                case .empty:
                    searchBar
                    emptyStateView
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.resetStateToLoaded()
                    })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .toolbar {
                topBarLeadingToolbarContent
                keyboardToolbarContent
            }
            .sheet(isPresented: $showInfoSheet) {
                InfoSheetView()
                    .presentationDragIndicator(.visible)
            }
        }
        .task {
            if viewModel.evDatabase.isEmpty {
                await viewModel.loadEVDatabase()
            }
        }
    }
    
    private var searchBar: some View {
        SearchBarView(searchText: $viewModel.searchText) {
            await viewModel.searchItems()
        }
        .focused($isPresented)
    }
    
    private var listContent: some View {
        List {
            ForEach(viewModel.evDatabase, id: \.id) { ev in
                NavigationLink(destination: EVDetailsView(evData: ev)) {
                    EVRowView(ev: ev)
                        .id(ev.id)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            }
            
            if viewModel.hasMoreListings && !viewModel.evDatabase.isEmpty {
                loadingIndicator
                    .task {
                        await viewModel.loadMoreEVDatabase()
                    }
            }
        }
        .listStyle(.plain)
    }
    
    private var topBarLeadingToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Clear") {
                viewModel.clearSearch()
            }
            .disabled(viewModel.searchText.isEmpty)
            
            Button(action: { showInfoSheet.toggle() }) {
                Image(systemName: "info.circle")
            }
        }
    }
    
    private var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer(minLength: 0)
            Button { isPresented = false } label: { Text("Done") }
        }
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .scaleEffect(1.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(UUID())
            .listRowSeparator(.hidden, edges: .all)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 5) {
            Image(systemName: "car.2.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            Text("No available data")
                .font(.headline)
            Text("Check back later for updates")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

fileprivate struct InfoSheetView: View {
    @State private var showSplashView: Bool = true
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                headerView
            
                Group {
                    if showSplashView {
                        CustomProgressView()
                            .frame(height: 600)
                    } else {
                        mainContent
                    }
                }
            }
            .padding()
            .padding(.top)
        }
        .onAppear {
            performAfterDelay(0.5) {
                withAnimation(.easeInOut) {
                    showSplashView = false
                }
            }
        }
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Welcome to our comprehensive Electric Vehicle (EV) database. This resource is designed to provide you with the most up-to-date and accurate information about electric vehicles available in the market.")
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Key Features:")
                    .font(.headline)
                
                bulletPoint("Manufacturer-sourced data for every single model")
                bulletPoint("Regular updates to ensure accuracy")
                bulletPoint("Comprehensive specifications for each EV")
                bulletPoint("User-friendly search functionality")
            }
            
            Text("Our team of experts meticulously collects and verifies information directly from manufacturers, ensuring that you have access to reliable and current data. Whether you're a potential buyer, an EV enthusiast, or a researcher, our database provides the insights you need.")
            
            Text("We update our database regularly to reflect new model releases, specification changes, and the latest developments in the rapidly evolving EV market.")
            
            Text("Explore our database to compare models, check specifications, and stay informed about the exciting world of electric vehicles!")
        }
    }
    
    private var headerView: some View {
        Text("About")
            .font(.title)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
    }
}

#Preview {
    EVListView()
}



