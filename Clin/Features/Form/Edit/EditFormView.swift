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
    
    @State private var isPromotionFinished: Bool = false
    @State var listing: Listing
        
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .idle:
                    mainContent
                    
                case .loading:
                    CustomProgressView(message: "Loading...")
                    
                case .uploading:
                    CircularProgressBar(progress: viewModel.imageManager.uploadingProgress)
                    
                case .success(let message):
                    SuccessView(
                        message: message,
                        doneAction: { viewModel.resetState(); dismiss() })
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        refreshMessage: "Try again",
                        retryAction: { viewModel.resetState() },
                        systemImage: "xmark.circle.fill")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Edit Listing")
        }
        .task {
            await viewModel.retrieveImages(listing: listing)
        }
    }
    
    private var mainContent: some View {
        EditFormSubview(
            viewModel: viewModel,
            listing: listing,
            isPromotionFinished: $isPromotionFinished)
        .toolbar {
            DismissView(action: {
                viewModel .resetState()
                dismiss()
                },
                isPromotionFinished: $isPromotionFinished)
        }
        .task {
            await viewModel.loadBulkData()
        }
    }
}

#Preview {
    EditFormView(listing: MockListingService.sampleData[0])
}

fileprivate struct EditFormSubview: View {
    @Bindable var viewModel: EditFormViewModel
    @Binding var isPromotionFinished: Bool
    
    @State var listing: Listing
    @State private var originalListing: Listing
   
    init(viewModel: EditFormViewModel, listing: Listing, isPromotionFinished: Binding<Bool>) {
        self._viewModel = Bindable(viewModel)
        self._listing = State(initialValue: listing)
        self._originalListing = State(initialValue: listing)
        self._isPromotionFinished = isPromotionFinished
    }
    
    var body: some View {
        ZStack {
            switch viewModel.subFormViewState {
            case .loading:
                CustomProgressView(message: "Loading...")
            case .loaded:
                Form {
                    makeSection
                    modelSection
                    subTitleSection
                    bodyTypeSection
                    yearConditionSection
                    mileageLocationSection
                    colourSection
                    rangeSection
                    priceSection
                    phoneSection
                    descriptionSection
                    powerSection
                    featuresSection
                    promoteListingSection
                    applyButtonSection
                }
                .toolbar {
                    keyboardToolbarContent
                    topBarTrailingToolbarContent
                }
            case .error(let message):
                ErrorView(
                    message: message,
                    refreshMessage: "Try again",
                    retryAction: { viewModel.resetState() },
                    systemImage: "xmark.circle.fill")
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
    
    private var subTitleSection: some View {
        Section(header: Text("Optional")) {
            TextField("Short subtitle", text: Binding(
                get: { self.listing.subTitle ?? "" },
                set: { self.listing.subTitle = $0.isEmpty ? nil : $0 }
            ))
            .characterLimit(Binding(
                get: { self.listing.subTitle ?? "" },
                set: { self.listing.subTitle = $0.isEmpty ? nil : $0 }
            ), limit: 20)
            .autocorrectionDisabled()
        }
    }

    private var bodyTypeSection: some View {
        Section("Body Type") {
            Picker("Body", selection: $listing.bodyType) {
                ForEach(viewModel.dataLoader.bodyTypeOptions, id: \.self) { body in
                    Text(body).tag(body)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var yearConditionSection: some View {
        Section(header: Text("Year and condition")) {
            Picker("Year of manufacture", selection: $listing.yearOfManufacture) {
                ForEach(viewModel.dataLoader.yearOptions, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            Picker("Condition", selection: $listing.condition) {
                ForEach(viewModel.dataLoader.conditionOptions, id: \.self) { condition in
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
                    
                TextField("Current mileage", value: $listing.mileage, format: .number)
                    .keyboardType(.decimalPad)
            }
            Picker("Location", selection: $listing.location) {
                ForEach(viewModel.dataLoader.availableLocations, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var colourSection: some View {
        Section("Colour and range") {
            Picker("Colour", selection: $listing.colour) {
                ForEach(viewModel.dataLoader.colourOptions, id: \.self) { colour in
                    Text(colour).tag(colour)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var rangeSection: some View {
        TextField("Driving range", value: $listing.range, format: .number)
            .keyboardType(.decimalPad)
    }
    
    private var priceSection: some View {
        Section("Price") {
            TextField("Asking price", value: $listing.price, format: .currency(code: "GBP").precision(.fractionLength(0)))
                .keyboardType(.decimalPad)
        }
    }
    
    private var phoneSection: some View {
        Section(header: Text("Contact number"), footer: phoneSectionFooter) {
            TextField("Phone", text: $listing.phoneNumber)
                .keyboardType(.phonePad)
                .onChange(of: listing.phoneNumber) { _, newValue in
                    listing.phoneNumber = newValue.formattedPhoneNumber
                }
        }
    }
    
    private var phoneSectionFooter: some View {
        Text("Please enter a valid 11-digit phone number")
            .foregroundStyle(.red.gradient)
            .opacity(!listing.phoneNumber.isValidPhoneNumber ? 1 : 0)
    }

    private var descriptionSection: some View {
        Section {
            TextEditor(text: $listing.textDescription)
                .frame(height: 300)
                .characterLimit($listing.textDescription, limit: 800)
        } header: {
            Text("Description (keep it simple)")
        } footer: {
            Text("\(listing.textDescription.count)/800")
        }
    }
    
    private var featuresSection: some View {
        Section {
            DisclosureGroup {
                homeChargingTime
                publicChargingTime
            } label: {
                Label("Charging times", systemImage: "ev.charger")
            }
            
            DisclosureGroup {
                additionalDataSection
            } label: {
                Label("Features", systemImage: "battery.100percent.bolt")
            }
        }
    }
    
    // MARK: - Feature Sections
    
    private var homeChargingTime: some View {
        Picker("Home", selection: $listing.homeChargingTime) {
            ForEach(viewModel.dataLoader.homeChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var publicChargingTime: some View {
        Picker("Public", selection: $listing.publicChargingTime) {
            ForEach(viewModel.dataLoader.publicChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var powerSection: some View {
        Section("HP") {
            TextField("HP", value: $listing.powerBhp, format: .number)
                .keyboardType(.numberPad)
        }
    }
    
    private var additionalDataSection: some View {
        Section {
            Picker("Battery capacity", selection: $listing.batteryCapacity) {
                ForEach(viewModel.dataLoader.batteryCapacityOptions, id: \.self) { battery in
                    Text(battery).tag(battery)
                }
            }
            
            Picker("Regenerative braking", selection: $listing.regenBraking) {
                ForEach(viewModel.dataLoader.regenBrakingOptions, id: \.self) { regen in
                    Text(regen).tag(regen)
                }
            }
            
            Picker("Warranty", selection: $listing.warranty) {
                ForEach(viewModel.dataLoader.warrantyOptions, id: \.self) { warranty in
                    Text(warranty).tag(warranty)
                }
            }
            
            Picker("Service history", selection: $listing.serviceHistory) {
                ForEach(viewModel.dataLoader.serviceHistoryOptions, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            
            Picker("Owners", selection: $listing.numberOfOwners) {
                ForEach(viewModel.dataLoader.numberOfOwnersOptions, id: \.self) { owners in
                    Text(owners).tag(owners)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    // MARK: - Payment
    private var promoteListingSection: some View {
        StoreKitView(isPromoted: $listing.isPromoted) {
            listing.isPromoted = true
            isPromotionFinished = true
        }
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
                ImagePickerGridView(viewModel: viewModel.imageManager)
            } label: {
                ImageCounterView(count: viewModel.imageManager.totalImageCount, isLoading: $viewModel.isRetrievingImage)
            }
            .allowsHitTesting(!viewModel.isRetrievingImage)
        }
    }
    
    // MARK: - Apply button
    private var applyButtonSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.updateUserListing(listing)
                    originalListing = listing
                    viewModel.imageManager.resetChangeFlag()
                }
            } label: {
                Text("Apply changes")
                    .foregroundStyle(listing == originalListing && !viewModel.imageManager.hasUserInitiatedChanges ? .gray.opacity(0.3) : .tabColour)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .disabled(listing == originalListing && !viewModel.imageManager.hasUserInitiatedChanges)
        }
    }
}

fileprivate struct DismissView: View {
    let action: () -> Void

    @Binding var isPromotionFinished: Bool
    
    var body: some View {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        action()
                    } label: {
                        Text("Cancel")
                    }
                    .disabled(isPromotionFinished)
                }
            }
    }
}
