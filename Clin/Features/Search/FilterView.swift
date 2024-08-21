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
            Form {
                Section(header: Text("Make and model ")) {
                    Picker("Make", selection: $viewModel.make) {
                        Text("Any").tag("Any")
                        ForEach(viewModel.fetchedMakeModels, id: \.make) { item in
                            Text(item.make).tag(item.make)
                        }
                    }
                    .onChange(of: viewModel.make) {
                        viewModel.updateAvailableModels()
                    }
                    Picker("Model", selection: $viewModel.model) {
                        ForEach(viewModel.availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
                .pickerStyle(.navigationLink)
                
                Section(header: Text("Year and condition")) {
                    Picker("Year of manufacture", selection:
                            $viewModel.selectedYear) {
                        ForEach(viewModel.yearOfManufacture, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    Picker("Condition", selection: $viewModel.condition) {
                        ForEach(viewModel.vehicleCondition, id: \.self) { condition in
                            Text(condition).tag(condition)
                        }
                    }
                }
                .pickerStyle(.navigationLink)
                
                Section(header: Text("Price and mileage")) {
                    Text("Max Price: \(viewModel.maxPrice, format: .currency(code: "GBP").precision(.fractionLength(0)))")
                    Slider(value: $viewModel.maxPrice, in: 0...100000, step: 1000) {
                        Text("Price")
                    }
                    Text("Max Mileage: \(viewModel.maxMileage, specifier: "%.0f") miles")
                    Slider(value: $viewModel.maxMileage, in: 0...500000, step: 1000) {
                        Text("Max Mileage")
                    }
                }
                
                DisclosureGroup("Other specification") {
                    Picker("Colour", selection: $viewModel.colour) {
                        ForEach(viewModel.availableColours, id: \.self) { colour in
                            Text(colour).tag(colour)
                        }
                    }
                    Picker("Warranty", selection: $viewModel.warranty) {
                        ForEach(viewModel.vehicleWarranty, id: \.self) { warranty in
                            Text(warranty).tag(warranty)
                        }
                    }
                    Picker("Service history", selection: $viewModel.serviceHistory) {
                        ForEach(viewModel.vehicleServiceHistory, id: \.self) { service in
                            Text(service).tag(service)
                        }
                    }
                    Picker("Owners", selection: $viewModel.numberOfOwners) {
                        ForEach(viewModel.vehicleNumberOfOwners, id: \.self) { owners in
                            Text(owners).tag(owners)
                        }
                    }
                }
                .pickerStyle(.navigationLink)
                    
                DisclosureGroup("EV specific") {
                    Picker("Range", selection: $viewModel.range) {
                        ForEach(viewModel.vehicleRange, id: \.self) { range in
                            Text(range).tag(range)
                        }
                    }
                    Picker("Public charging time", selection: $viewModel.maxPublicChargingTime) {
                        ForEach(viewModel.publicCharge, id: \.self) { time in
                            Text(time).tag(time)
                        }
                    }
                    Picker("Home charging time", selection: $viewModel.maxHomeChargingTime) {
                        ForEach(viewModel.homeCharge, id: \.self) { time in
                            Text(time).tag(time)
                        }
                    }
                    Picker("Power BHP", selection: $viewModel.powerBhp) {
                        ForEach(viewModel.vehiclePowerBhp, id: \.self) { power in
                            Text(power).tag(power)
                        }
                    }
                    Picker("Battery capacity", selection: $viewModel.batteryCapacity) {
                        ForEach(viewModel.batteryCap, id: \.self) { battery in
                            Text(battery).tag(battery)
                        }
                    }

                    Picker("Regen braking", selection: $viewModel.regenBraking) {
                        ForEach(viewModel.vehicleRegenBraking, id: \.self) { regen in
                            Text(regen).tag(regen)
                        }
                    }
                }
                .pickerStyle(.navigationLink)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        Task {
                            await viewModel.fetchFilteredItems()
                            onApply()
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset filters") {
                        viewModel.resetFilters()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchMakeModels()
            await viewModel.fetchEvSpecifications()
            await viewModel.fetchAvailableColours()
        }
    }
}

#Preview {
    FilterView(viewModel: SearchViewModel(), onApply: {})
}
