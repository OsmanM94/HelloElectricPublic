//
//  EditListingView.swift
//  Clin
//
//  Created by asia on 27/07/2024.
//

import SwiftUI


struct EditFormView: View {
    @StateObject private var viewModel = EditFormViewModel()
    @Environment(\.dismiss) private var dismiss
    @State var listing: Listing
    
    var body: some View {
        NavigationStack {
            Group {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .idle:
                        EditFormSubview(viewModel: viewModel, listing: listing)
                            .toolbar { DismissView(action: {
                                viewModel.resetState(); dismiss() }) }
                        
                    case .loading:
                        CustomProgressView()
                        
                    case .uploading:
                        CircularProgressBar(progress: viewModel.uploadingProgress)
                        
                    case .success(let message):
                        SuccessView(message: message, doneAction: { viewModel.resetState(); dismiss() })
                        
                    case .error(let message):
                        ErrorView(message: message, retryAction: { viewModel.resetState() })
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            }
            .navigationTitle("Edit Listing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadProhibitedWords()
        }
    }
}

#Preview {
    EditFormView(listing: MockListingService.sampleData[0])
}

fileprivate struct EditFormSubview: View {
    @ObservedObject var viewModel: EditFormViewModel
    @State var listing: Listing
    
    var body: some View {
        Form {
            makeSection
            modelSection
            conditionSection
            mileageSection
            yearOfManufactureSection
            averageRangeSection
            priceSection
            descriptionSection
            featuresSection
            applyButtonSection
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer(minLength: 0)
                Button {
                    hideKeyboard()
                } label: {
                    Text("Done")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ImagePickerGridView(viewModel: viewModel)
                        .task {
                            await viewModel.loadListingData(listing: listing)
                        }
                } label: {
                    Image(systemName: "photo")
                        .foregroundStyle(.gray)
                        .font(.system(size: 24))
                        .overlay(alignment: .topTrailing) {
                            Text("\(viewModel.totalImageCount)")
                                .font(.system(size: 13).bold())
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(Color(.red))
                                .clipShape(Circle())
                                .offset(x: 4, y: -8)
                        }
                }
            }
        }
    }
}

private extension EditFormSubview {
    var makeSection: some View {
        Section("Make") {
            Label(listing.make, systemImage: "lock")
        }
    }
    
    var modelSection: some View {
        Section("Model") {
            Label(listing.model, systemImage: "lock")
        }
    }
    
    var conditionSection: some View {
        Section("Condition") {
            Picker("Vehicle condition", selection: $listing.condition) {
                ForEach(viewModel.vehicleCondition, id: \.self) { condition in
                    Text(condition).tag(condition)
                }
            }
        }
    }
    
    var mileageSection: some View {
        Section("Mileage") {
            TextField("Current mileage", value: $listing.mileage, format: .number)
                .keyboardType(.decimalPad)
        }
    }
    
    var yearOfManufactureSection: some View {
        Section("Year of manufacture") {
            Picker("\(listing.yearOfManufacture)", selection: $listing.yearOfManufacture) {
                ForEach(viewModel.yearsOfmanufacture, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
        }
    }
    
    var averageRangeSection: some View {
        Section("Average Range") {
            TextField("What is the average range?", text: $listing.range)
                .keyboardType(.decimalPad)
                .characterLimit($listing.range, limit: 4)
        }
    }
    
    var priceSection: some View {
        Section("Price") {
            TextField("Asking price", value: $listing.price, format: .currency(code: "GBP").precision(.fractionLength(0)))
                .keyboardType(.decimalPad)
        }
    }
    
    var descriptionSection: some View {
        Section {
            TextEditor(text: $listing.textDescription)
                .frame(minHeight: 150)
                .characterLimit($listing.textDescription, limit: 500)
        } header: {
            Text("Description")
        } footer: {
            Text("\(listing.textDescription.count)/500")
        }
    }
    
    var featuresSection: some View {
        Section("Features") {
            chargingTimesDisclosureGroup
            batteryCapacityDisclosureGroup
            additionalDataDisclosureGroup
        }
    }
    
    var applyButtonSection: some View {
        Section {
            Button {
                Task { await viewModel.updateUserListing(listing) }
            } label: {
                Text("Apply")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.green.opacity(0.8))
        }
    }
    
    var chargingTimesDisclosureGroup: some View {
        DisclosureGroup {
            HStack(spacing: 5) {
                Text("H:")
                TextField("Estimated home time charging", text: $listing.homeChargingTime)
                    .characterLimit($listing.homeChargingTime, limit: 30)
            }
            HStack(spacing: 5) {
                Text("P:")
                TextField("Estimated public time charging", text: $listing.publicChargingTime)
                    .characterLimit($listing.publicChargingTime, limit: 30)
            }
        } label: {
            Label("Charging times", systemImage: "ev.charger")
        }
    }
    
    var batteryCapacityDisclosureGroup: some View {
        DisclosureGroup {
            HStack(spacing: 5) {
                Text("kWh:")
                TextField("", text: $listing.batteryCapacity)
                    .characterLimit($listing.batteryCapacity, limit: 5)
                    .keyboardType(.decimalPad)
            }
        } label: {
            Label("Battery capacity", systemImage: "battery.100percent.bolt")
        }
    }
    
    var additionalDataDisclosureGroup: some View {
        DisclosureGroup {
            HStack(spacing: 5) {
                Text("BHP:")
                TextField("What is the bhp power?", text: $listing.powerBhp)
                    .keyboardType(.decimalPad)
                    .characterLimit($listing.powerBhp, limit: 5)
            }
            Picker("Regen braking", selection: $listing.regenBraking) {
                ForEach(viewModel.vehicleRegenBraking, id: \.self) { regen in
                    Text(regen).tag(regen)
                }
            }
            Picker("Warranty", selection: $listing.warranty) {
                ForEach(viewModel.vehicleWarranty, id: \.self) { warranty in
                    Text(warranty).tag(warranty)
                }
            }
            Picker("Service history", selection: $listing.serviceHistory) {
                ForEach(viewModel.vehicleServiceHistory, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            Picker("How many owners?", selection: $listing.numberOfOwners) {
                ForEach(viewModel.vehicleNumberOfOwners, id: \.self) { owners in
                    Text(owners).tag(owners)
                }
            }
        } label: {
            Label("Additional data", systemImage: "gear")
        }
    }
}

fileprivate struct DismissView: View {
    let action: () -> Void
    var body: some View {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        action()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
    }
}
