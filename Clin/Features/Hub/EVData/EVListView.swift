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
                    CustomProgressView(message: "Loading...")
                    
                case .loaded:
                    searchBar
                    updatedSection
                    listContent
                    
                    
                case .empty:
                    searchBar
                    emptyStateView
                    
                case .error(let message):
                    ErrorView(message: message,
                              refreshMessage: "Try again",
                              retryAction: {
                        viewModel.resetStateToLoaded()
                    }, systemImage: "xmark.circle.fill")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .toolbar {
                topBarTrailingToolbarContent
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
    
    private var menuSection: some View {
        Menu {
            Picker("Filters", selection: $viewModel.databaseFilter) {
                ForEach(DatabaseFilter.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)
            
            Button(action: { showInfoSheet.toggle() }) {
                Text("About database")
            }
            
        } label: {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Menu")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6).opacity(0.8))
            .clipShape(Capsule())
        }
        .onChange(of: viewModel.databaseFilter) { _, newValue in
            Task { await viewModel.loadEVDatabase() }
        }
        .disabled(viewModel.viewState == .loading)
    }
    
    private var updatedSection: some View {
        Text("Updated: \(Date.now.formatted(date: .numeric, time: .omitted))")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)
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
                    .task { await viewModel.loadMoreFromDatabase() }
            }
        }
        .listStyle(.plain)
    }
    
    private var topBarTrailingToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            menuSection
        }
    }
    
    private var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("Clear") {
                viewModel.clearSearch()
            }
            .disabled(viewModel.searchText.isEmpty)
            
            Spacer()
            
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
        ScrollView {
            VStack(spacing: 20) {
                headerView
            
                Group {
                    if showSplashView {
                        CustomProgressView(message: "")
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
            
            Text("Welcome to our Electric Vehicle (EV) database. This resource is designed to provide you with the most up-to-date and accurate information about electric vehicles available in the market.")
            
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
    NavigationStack {
        EVListView()
    }
}



