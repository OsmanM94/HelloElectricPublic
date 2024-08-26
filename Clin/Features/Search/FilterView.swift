//
//  FilterView.swift
//  Clin
//
//  Created by asia on 14/08/2024.
//

import SwiftUI

struct FilterView: View {
    @Bindable var viewModel: SearchViewModel
    let onApply: () -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.filterViewState {
                    case .loading:
                        CustomProgressView()
                    case .loaded:
                        FilterSubView(viewModel: viewModel, onApply: onApply)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.filterViewState)
                .navigationTitle("Filters")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await viewModel.loadBulkData()
        }
    }
}

fileprivate struct FilterSubView: View {
    @Bindable var viewModel: SearchViewModel
    let onApply: () -> Void
    
    var body: some View {
        Form {
            MakeModelSection(viewModel: viewModel)
            bodyTypeSection(viewModel: viewModel)
            YearConditionSection(viewModel: viewModel)
            LocationSection(viewModel: viewModel)
            PriceMileageSection(viewModel: viewModel)
            OtherSpecificationsSection(viewModel: viewModel)
            EVSpecificationsSection(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Apply") {
                    Task {
                        await viewModel.searchFilteredItems()
                        onApply()
                    }
                }
                .disabled(!viewModel.isFilterApplied)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Reset") {
                    viewModel.resetFilters()
                }
                .disabled(!viewModel.isFilterApplied)
            }
        }
    }
}

fileprivate struct MakeModelSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section(header: Text("Make and model ")) {
            Picker("Make", selection: $viewModel.make) {
                ForEach(viewModel.makeOptions, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .onChange(of: viewModel.make) {
                viewModel.updateAvailableModels()
            }
            Picker("Model", selection: $viewModel.model) {
                ForEach(viewModel.modelOptions, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .disabled(viewModel.make.isEmpty || viewModel.make == "Any")
        }
        .pickerStyle(.navigationLink)
    }
}

fileprivate struct bodyTypeSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section("Body Type") {
            Picker("Body", systemImage: "car.fill", selection: $viewModel.body) {
                ForEach(viewModel.bodyTypeOptions, id: \.self) { body in
                    Text(body).tag(body)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
}

fileprivate struct YearConditionSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section(header: Text("Year and condition")) {
            Picker("Year of manufacture", systemImage: "licenseplate.fill", selection: $viewModel.selectedYear) {
                ForEach(viewModel.yearOptions, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            
            Picker("Condition", systemImage: "axle.2", selection: $viewModel.condition) {
                ForEach(viewModel.conditionOptions, id: \.self) { condition in
                    Text(condition).tag(condition)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
}

fileprivate struct LocationSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section("Location") {
            Picker("Location", systemImage: "location.fill.viewfinder", selection: $viewModel.location) {
                ForEach(viewModel.availableLocations, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
}

fileprivate struct PriceMileageSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section(header: Text("Price and mileage")) {
            Text("Max Price: \(viewModel.maxPrice, format: .currency(code: "GBP").precision(.fractionLength(0)))")
            Slider(value: $viewModel.maxPrice, in: 0...100_000, step: 1000) {
                Text("Price")
            }
            Text("Max Mileage: \(viewModel.maxMileage, specifier: "%.0f") miles")
            Slider(value: $viewModel.maxMileage, in: 0...300_000, step: 1000) {
                Text("Max Mileage")
            }
        }
    }
}

fileprivate struct OtherSpecificationsSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        DisclosureGroup {
            Picker("Colour", selection: $viewModel.colour) {
                ForEach(viewModel.colourOptions, id: \.self) { colour in
                    Text(colour).tag(colour)
                }
            }
            Picker("Warranty", selection: $viewModel.warranty) {
                ForEach(viewModel.warrantyOptions, id: \.self) { warranty in
                    Text(warranty).tag(warranty)
                }
            }
            Picker("Service history", selection: $viewModel.serviceHistory) {
                ForEach(viewModel.serviceHistoryOptions, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            Picker("Owners", selection: $viewModel.numberOfOwners) {
                ForEach(viewModel.numberOfOwnersOptions, id: \.self) { owners in
                    Text(owners).tag(owners)
                }
            }
        } label: {
            Label("Other", systemImage: "doc.plaintext.fill")
        }
        .pickerStyle(.navigationLink)
    }
}

fileprivate struct EVSpecificationsSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        DisclosureGroup {
            Picker("Driving range", selection: $viewModel.range) {
                ForEach(viewModel.rangeOptions, id: \.self) { range in
                    Text(range).tag(range)
                }
            }
            Picker("Public charging time", selection: $viewModel.maxPublicChargingTime) {
                ForEach(viewModel.publicChargingTimeOptions, id: \.self) { time in
                    Text(time).tag(time)
                }
            }
            Picker("Home charging time", selection: $viewModel.maxHomeChargingTime) {
                ForEach(viewModel.homeChargingTimeOptions, id: \.self) { time in
                    Text(time).tag(time)
                }
            }
            Picker("Power BHP", selection: $viewModel.powerBhp) {
                ForEach(viewModel.powerBhpOptions, id: \.self) { power in
                    Text(power).tag(power)
                }
            }
            Picker("Battery capacity", selection: $viewModel.batteryCapacity) {
                ForEach(viewModel.batteryCapacityOptions, id: \.self) { battery in
                    Text(battery).tag(battery)
                }
            }
            Picker("Regen braking", selection: $viewModel.regenBraking) {
                ForEach(viewModel.regenBrakingOptions, id: \.self) { regen in
                    Text(regen).tag(regen)
                }
            }
        } label: {
            Label("EV specifications", systemImage: "bolt.batteryblock.fill")
        }
        .pickerStyle(.navigationLink)
    }
}

#Preview {
    let _ = PreviewsProvider.shared.container.searchService.register { MockSearchService() }
    FilterView(viewModel: SearchViewModel(), onApply: {})
}
