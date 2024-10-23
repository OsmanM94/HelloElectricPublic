//
//  FilterView.swift
//  Clin
//
//  Created by asia on 14/08/2024.
//

import SwiftUI

struct FilterView: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.filterViewState {
                    case .loading:
                        CustomProgressView(message: "")
                        
                    case .loaded:
                        FilterSubView(viewModel: viewModel)
                        
                    case .error(let message):
                        ErrorView(message: message,
                                  refreshMessage: "Try again",
                                  retryAction: {
                            await viewModel.loadBulkData()
                        }, systemImage: "xmark.circle.fill")
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.filterViewState)
                .navigationTitle("Filters")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task { await viewModel.loadBulkData() }
    }
}

fileprivate struct FilterSubView: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        Form {
            MakeModelSection(viewModel: viewModel)
            BodyTypeSection(viewModel: viewModel)
            YearConditionSection(viewModel: viewModel)
            LocationSection(viewModel: viewModel)
            PriceMileageSection(viewModel: viewModel)
            RangeSection(viewModel: viewModel)
            HpSection(viewModel: viewModel)
            OtherSpecificationsSection(viewModel: viewModel)
            EVSpecificationsSection(viewModel: viewModel)
        }
        .toolbar {
            toolbarTrailing
            toolbarLeading
        }
        .onChange(of: viewModel.isFilterAppliedSuccessfully) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
    
    private var toolbarLeading: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.resetFilters()
            } label: {
                Text("Reset")
                    .foregroundStyle(!viewModel.filters.isFilterApplied ? .gray.opacity(0.5) : .red)
            }
            .disabled(!viewModel.filters.isFilterApplied)
        }
    }
    
    private var toolbarTrailing: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task { await viewModel.searchFilteredItems() }
            } label: {
                Group {
                    if viewModel.isLoadingAppliedFilters {
                        ProgressView()
                    } else {
                        Text("Apply")
                    }
                }
            }
            .disabled(!viewModel.filters.isFilterApplied || viewModel.isLoadingAppliedFilters)
        }
    }
}

fileprivate struct MakeModelSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section(header: headerSection, footer: footerSection) {
            Picker("Make", selection: $viewModel.filters.make) {
                ForEach(viewModel.dataLoader.makeOptions, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .onChange(of: viewModel.filters.make) {
                viewModel.updateAvailableModels()
            }
            
            Picker("Model", selection: $viewModel.filters.model) {
                ForEach(viewModel.dataLoader.modelOptions, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .disabled(viewModel.filters.make.isEmpty || viewModel.filters.make == "Any")
        }
        .pickerStyle(.navigationLink)
        
    }
    
    private var headerSection: some View {
        Text("Made and model")
    }
    
    private var footerSection: some View {
        MissingDataSupport(buttonText: "Missing vehicles?")
    }
}

fileprivate struct BodyTypeSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section("Body Type") {
            Picker("Body", systemImage: "car.fill", selection: $viewModel.filters.body) {
                ForEach(viewModel.dataLoader.bodyTypeOptions, id: \.self) { body in
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
            Picker("Year of manufacture", systemImage: "licenseplate.fill", selection: $viewModel.filters.selectedYear) {
                ForEach(viewModel.dataLoader.yearOptions, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            
            Picker("Condition", systemImage: "axle.2", selection: $viewModel.filters.condition) {
                ForEach(viewModel.dataLoader.conditionOptions, id: \.self) { condition in
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
            Picker("Location", systemImage: "location.fill.viewfinder", selection: $viewModel.filters.location) {
                ForEach(viewModel.dataLoader.availableLocations, id: \.self) { city in
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
            Text("Max Price: \(viewModel.filters.maxPrice, format: .currency(code: "GBP").precision(.fractionLength(0)))")
            Slider(value: $viewModel.filters.maxPrice, in: 0...100_000, step: 1000) {
                Text("Price")
            }
            .tint(.tabColour)
            
            Text("Max Mileage: \(viewModel.filters.maxMileage, specifier: "%.0f") miles")
            Slider(value: $viewModel.filters.maxMileage, in: 0...300_000, step: 1000) {
                Text("Max Mileage")
            }
            .tint(.tabColour)
        }
    }
}

fileprivate struct RangeSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section("Range up to 1000") {
            TextField("Range", value: $viewModel.filters.range, format: .number.precision(.fractionLength(0)))
                .keyboardType(.numberPad)
        }
    }
}

fileprivate struct HpSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Section("HP up to 1000") {
            TextField("HP", value: $viewModel.filters.powerBhp, format: .number.precision(.fractionLength(0)))
                .keyboardType(.numberPad)
        }
    }
}

fileprivate struct OtherSpecificationsSection: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        DisclosureGroup {
            Picker("Colour", selection: $viewModel.filters.colour) {
                ForEach(viewModel.dataLoader.colourOptions, id: \.self) { colour in
                    Text(colour).tag(colour)
                }
            }
            Picker("Warranty", selection: $viewModel.filters.warranty) {
                ForEach(viewModel.dataLoader.warrantyOptions, id: \.self) { warranty in
                    Text(warranty).tag(warranty)
                }
            }
            Picker("Service history", selection: $viewModel.filters.serviceHistory) {
                ForEach(viewModel.dataLoader.serviceHistoryOptions, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            Picker("Owners", selection: $viewModel.filters.numberOfOwners) {
                ForEach(viewModel.dataLoader.numberOfOwnersOptions, id: \.self) { owners in
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
            Picker("Public charging time", selection: $viewModel.filters.maxPublicChargingTime) {
                ForEach(viewModel.dataLoader.publicChargingTimeOptions, id: \.self) { time in
                    Text(time).tag(time)
                }
            }
            Picker("Home charging time", selection: $viewModel.filters.maxHomeChargingTime) {
                ForEach(viewModel.dataLoader.homeChargingTimeOptions, id: \.self) { time in
                    Text(time).tag(time)
                }
            }
            Picker("Battery capacity", selection: $viewModel.filters.batteryCapacity) {
                ForEach(viewModel.dataLoader.batteryCapacityOptions, id: \.self) { battery in
                    Text(battery).tag(battery)
                }
            }
            Picker("Regenerative braking", selection: $viewModel.filters.regenBraking) {
                ForEach(viewModel.dataLoader.regenBrakingOptions, id: \.self) { regen in
                    Text(regen).tag(regen)
                }
            }
        } label: {
            Label("Features", systemImage: "bolt.batteryblock.fill")
        }
        .pickerStyle(.navigationLink)
    }
}

#Preview {
    FilterView(viewModel: SearchViewModel())
}
