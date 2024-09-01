//
//  EditListingView.swift
//  Clin
//
//  Created by asia on 27/07/2024.
//

import SwiftUI

struct EditFormView: View {
    @State private var viewModel = EditFormViewModel()
    @Environment(\.dismiss) private var dismiss
    @State var listing: Listing
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch viewModel.viewState {
                case .idle:
                    EditFormSubview(viewModel: viewModel, listing: listing)
                        .toolbar { DismissView(action: {
                            viewModel.resetState(); dismiss() }) }
                        .task { await viewModel.loadBulkData() }
                    
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
            .navigationTitle("Edit Listing")
        }
        .task {
            await viewModel.retrieveImages(listing: listing)
        }
    }
}

#Preview {
    EditFormView(listing: MockListingService.sampleData[0])
}

fileprivate struct EditFormSubview: View {
    @Bindable var viewModel: EditFormViewModel
    @State var listing: Listing
    @State private var originalListing: Listing
    
    init(viewModel: EditFormViewModel, listing: Listing) {
        self._viewModel = Bindable(viewModel)
        self._listing = State(initialValue: listing)
        self._originalListing = State(initialValue: listing)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.subFormViewState {
            case .loading:
                CustomProgressView()
            case .loaded:
                Form {
                    makeSection
                    modelSection
                    bodyTypeSection
                    yearConditionSection
                    mileageLocationSection
                    colourRangeSection
                    priceSection
                    phoneSection
                    descriptionSection
                    featuresSection
                    applyButtonSection
                }
                .toolbar {
                    keyboardToolbarContent
                    topBarTrailingToolbarContent
                }
                .onTapGesture {
                    hideKeyboard()
                }
//                .onChange(of: viewModel.selectedImages) { _, _ in
//                    hasImageChanges = true
//                }
            case .error(let message):
                ErrorView(message: message) { viewModel.resetState() }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.subFormViewState)
    }
    
    // MARK: - Sections
    
    private var makeSection: some View {
        Section("Make") {
            Label(listing.make, systemImage: "lock.fill")
        }
    }
    
    private var modelSection: some View {
        Section("Model") {
            Label(listing.model, systemImage: "lock.fill")
        }
    }

    private var bodyTypeSection: some View {
        Section("Body Type") {
            Picker("Body", selection: $listing.bodyType) {
                ForEach(viewModel.bodyTypeOptions, id: \.self) { body in
                    Text(body).tag(body)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var yearConditionSection: some View {
        Section(header: Text("Year and condition")) {
            Picker("Year of manufacture", selection: $listing.yearOfManufacture) {
                ForEach(viewModel.yearOptions, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            Picker("Condition", selection: $listing.condition) {
                ForEach(viewModel.conditionOptions, id: \.self) { condition in
                    Text(condition).tag(condition)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var mileageLocationSection: some View {
        Section("Mileage and location") {
            HStack(spacing: 15) {
                Image(systemName: "gauge.with.needle")
                    .imageScale(.large)
                    .foregroundStyle(.green)
                TextField("Current mileage", value: $listing.mileage, format: .number)
                    .keyboardType(.decimalPad)
            }
            Picker("Location", selection: $listing.location) {
                ForEach(viewModel.availableLocations, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var colourRangeSection: some View {
        Section("Colour and range") {
            Picker("Colour", selection: $listing.colour) {
                ForEach(viewModel.colourOptions, id: \.self) { colour in
                    Text(colour).tag(colour)
                }
            }
            Picker("Driving range", selection: $listing.range) {
                ForEach(viewModel.rangeOptions, id: \.self) { range in
                    Text(range).tag(range)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var priceSection: some View {
        Section("Price") {
            TextField("Asking price", value: $listing.price, format: .currency(code: "GBP").precision(.fractionLength(0)))
                .keyboardType(.decimalPad)
        }
    }
    
    private var phoneSection: some View {
        Section("Contact number") {
            TextField("Phone", text: $listing.phoneNumber)
                .keyboardType(.phonePad)
                .characterLimit($listing.phoneNumber, limit: 11)
        }
    }

    private var descriptionSection: some View {
        Section {
            TextEditor(text: $listing.textDescription)
                .frame(minHeight: 150)
                .characterLimit($listing.textDescription, limit: 500)
        } header: {
            Text("Description (keep it simple)")
        } footer: {
            Text("\(listing.textDescription.count)/500")
        }
    }
    
    private var featuresSection: some View {
        Section("Features") {
            DisclosureGroup {
                homeChargingTime
                publicChargingTime
            } label: {
                Label("Charging times", systemImage: "ev.charger")
            }
            
            DisclosureGroup {
                additionalDataSection
            } label: {
                Label("Additional features", systemImage: "battery.100percent.bolt")
            }
        }
    }
    
    // MARK: - Feature Sections
    
    private var homeChargingTime: some View {
        Picker("Home", selection: $listing.homeChargingTime) {
            ForEach(viewModel.homeChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var publicChargingTime: some View {
        Picker("Public", selection: $listing.publicChargingTime) {
            ForEach(viewModel.publicChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var additionalDataSection: some View {
        Section {
            Picker("Power BHP", selection: $listing.powerBhp) {
                ForEach(viewModel.powerBhpOptions, id: \.self) { power in
                    Text(power).tag(power)
                }
            }
            
            Picker("Battery capacity", selection: $listing.batteryCapacity) {
                ForEach(viewModel.batteryCapacityOptions, id: \.self) { battery in
                    Text(battery).tag(battery)
                }
            }
            
            Picker("Regen braking", selection: $listing.regenBraking) {
                ForEach(viewModel.regenBrakingOptions, id: \.self) { regen in
                    Text(regen).tag(regen)
                }
            }
            
            Picker("Warranty", selection: $listing.warranty) {
                ForEach(viewModel.warrantyOptions, id: \.self) { warranty in
                    Text(warranty).tag(warranty)
                }
            }
            
            Picker("Service history", selection: $listing.serviceHistory) {
                ForEach(viewModel.serviceHistoryOptions, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            
            Picker("Owners", selection: $listing.numberOfOwners) {
                ForEach(viewModel.numberOfOwnersOptions, id: \.self) { owners in
                    Text(owners).tag(owners)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    // MARK: Toolbar
    private var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer(minLength: 0)
            Button {
                hideKeyboard()
            } label: {
                Text("Done")
            }
        }
    }
    
    private var topBarTrailingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                ImagePickerGridView(viewModel: viewModel)
            } label: {
                ImageCounterView(count: viewModel.totalImageCount)
            }
        }
    }
    
    // MARK: - Apply button
    private var applyButtonSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.updateUserListing(listing)
                    originalListing = listing
                }
            } label: {
                Text("Apply")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .disabled(listing == originalListing)
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
