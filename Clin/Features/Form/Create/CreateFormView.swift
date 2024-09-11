//
//  UploadListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI

struct CreateFormView: View {
    @State private var viewModel = CreateFormViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .idle:
                    DvlaCheckView(
                        registrationNumber: $viewModel.registrationNumber,
                        sendDvlaRequest:
                            { await viewModel.sendDvlaRequest() })
                    
                case .loading:
                    CustomProgressView()
                    
                case .loaded:
                    CreateFormSubview(viewModel: viewModel)
                        .task { await viewModel.loadBulkData() }
                case .uploading:
                    CircularProgressBar(progress: viewModel.imageManager.uploadingProgress)
                    
                case .success(let message):
                    SuccessView(message: message, doneAction: { viewModel.resetFormDataAndState() })
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.resetFormDataAndState()
                    })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Selling")
        }
    }
}

#Preview("DVLA") {
    CreateFormView()
}

#Preview("Loaded") {
    NavigationStack {
        CreateFormSubview(viewModel: CreateFormViewModel())
    }
}

// MARK: - DVLA Check
fileprivate struct DvlaCheckView: View {
    @Binding var registrationNumber: String
    @State private var showInfoPopover: Bool = false
    var sendDvlaRequest: () async -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(.secondarySystemBackground))
                .ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Text("UK Registration")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        showInfoPopover = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                    }
                    .popover(isPresented: $showInfoPopover, arrowEdge: .top) {
                        infoPopoverContent
                            .presentationCompactAdaptation(.sheet)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    }
                }
                
                registrationPlate
                
                Spacer(minLength: 0)
            }
            .padding()
        }
    }
    
    private var registrationPlate: some View {
        HStack(spacing: 0) {
            Rectangle()
                .foregroundStyle(.green)
                .frame(width: 40)
                .overlay {
                    Text("UK")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(0))
                }
            
            TextField("", text: $registrationNumber, prompt: Text("Enter registration").foregroundStyle(.gray.opacity(0.7)))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding()
                .background(Color.yellow.opacity(0.8))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onChange(of: registrationNumber) {
                    registrationNumber = registrationNumber.uppercased()
                }
                .onSubmit {
                    Task {
                        guard !registrationNumber.isEmpty else { return }
                        await sendDvlaRequest()
                    }
                }
        }
        .frame(height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 3)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var infoPopoverContent: some View {
        GroupBox("Why is this step required?") {
            VStack(alignment: .leading, spacing: 10) {
                Text("We need to check the vehicle's registration to verify if it's an electric vehicle (EV).")
                
                Text("This marketplace is exclusively for electric vehicles, so we can only proceed with listings for confirmed EVs.")
                
                Text("If the vehicle is not electric, we won't be able to continue with the listing process.")
                    .padding(.top, 5)
            }
            .fontDesign(.rounded)
            .padding(.top)
        }
        .padding()
    }
}

fileprivate struct CreateFormSubview: View {
    @Bindable var viewModel: CreateFormViewModel
    @State private var showLocationPopover: Bool = false
    var body: some View {
        ZStack {
            switch viewModel.subFormViewState {
            case .loading:
                CustomProgressView()
            case .loaded:
                Form {
                    makeModelSection
                    bodyTypeSection
                    yearConditionSection
                    mileageSection
                    locationSection
                    colourRangeSection
                    priceSection
                    phoneSection
                    descriptionSection
                    featuresSection
                    paymentSection
                    createButtonSection
                }
                .toolbar {
                    topBarLeadingToolbarContent
                    keyboardToolbarContent
                    topBarTrailingToolbarContent
                }
            case .error(let message):
                ErrorView(message: message) { viewModel.resetFormDataAndState() }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.subFormViewState)
    }
    
    // MARK: - Sections
    
    private var makeModelSection: some View {
        Section(header: Text("Make and model "), footer: makeModelFooter) {
            Picker("Make", selection: $viewModel.formData.make) {
                ForEach(viewModel.dataLoader.makeOptions, id: \.self) { make in
                    Text(make).tag(make)
                }
            }
            .onChange(of: viewModel.formData.make) {
                viewModel.updateAvailableModels()
            }
            Picker("Model", selection: $viewModel.formData.model) {
                ForEach(viewModel.dataLoader.modelOptions, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .disabled(viewModel.formData.make == "Select")
            
        }
        .pickerStyle(.navigationLink)
    }
    
    private var makeModelFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected make and model cannot be changed later.")
            SupportButton(buttonText: "Missing models?")
        }
    }
    
    private var bodyTypeSection: some View {
        Section("Body Type") {
            Picker("Body", systemImage: "car.fill", selection: $viewModel.formData.body) {
                ForEach(viewModel.dataLoader.bodyTypeOptions, id: \.self) { body in
                    Text(body).tag(body)
                }
            }
            .disabled(viewModel.formData.make == "Select" || viewModel.formData.model == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    private var yearConditionSection: some View {
        Section(header: Text("Year and condition")) {
            Picker("Year of manufacture", systemImage: "licenseplate.fill", selection: $viewModel.formData.selectedYear) {
                ForEach(viewModel.dataLoader.yearOptions, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            .disabled(viewModel.formData.body == "Select")
            
            Picker("Condition", systemImage: "axle.2", selection: $viewModel.formData.condition) {
                ForEach(viewModel.dataLoader.conditionOptions, id: \.self) { condition in
                    Text(condition).tag(condition)
                }
            }
            .disabled(viewModel.formData.selectedYear == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    private var mileageSection: some View {
        Section("Mileage and location") {
            HStack(spacing: 15) {
                Image(systemName: "gauge.with.needle")
                    .imageScale(.large)
                    .foregroundStyle(viewModel.formData.condition == "Select" ? .green.opacity(0.5) : .green)
                TextField("Current mileage", value: $viewModel.formData.mileage, format: .number)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(viewModel.formData.condition == "Select" ? .gray : .primary)
                    .opacity(viewModel.formData.condition == "Select" ? 0.8 : 1)
            }
            .disabled(viewModel.formData.condition == "Select")
        }
    }
    
    private var locationSection: some View {
        Section(footer: locationHeader) {
            HStack {
                Picker("Location", selection: $viewModel.formData.location) {
                    ForEach(viewModel.dataLoader.availableLocations, id: \.self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(.navigationLink)
                .disabled(viewModel.formData.mileage == 500)
            }
        }
    }
    
    private var locationHeader: some View {
        Button(action: { showLocationPopover.toggle() }) {
            Image(systemName: "info.circle")
                .foregroundStyle(.blue)
        }
        .popover(isPresented: $showLocationPopover, arrowEdge: .top) {
            locationInfoPopover
        }
    }
    
    private var locationInfoPopover: some View {
        GroupBox("Location information") {
            VStack(alignment: .leading, spacing: 10) {
                Text("The location selection is pre-selected for privacy reasons. We don't collect your personal location information.")
                
                Text("You can choose a nearby city to indicate your general area.")
            }
            .fontDesign(.rounded)
            .padding(.top)
        }
        .padding(.horizontal)
    }

    private var colourRangeSection: some View {
        Section("Colour and range") {
            Picker("Colour", systemImage: "paintpalette.fill" ,selection: $viewModel.formData.colour) {
                ForEach(viewModel.dataLoader.colourOptions, id: \.self) { colour in
                    Text(colour).tag(colour)
                }
            }
            .disabled(viewModel.formData.location == "Select")
            
            Picker("Driving range", systemImage: "road.lanes", selection: $viewModel.formData.range) {
                ForEach(viewModel.dataLoader.rangeOptions, id: \.self) { range in
                    Text(range).tag(range)
                }
            }
            .disabled(viewModel.formData.colour == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    private var priceSection: some View {
        Section("Price") {
            TextField("Asking price", value: $viewModel.formData.price, format: .currency(code: "GBP").precision(.fractionLength(0)))
                .keyboardType(.decimalPad)
                .foregroundStyle(viewModel.formData.range == "Select" ? .gray : .primary)
                .opacity(viewModel.formData.range == "Select" ? 0.8 : 1)
                .disabled(viewModel.formData.range == "Select")
            
        }
    }
    
    private var phoneSection: some View {
        Section(header: Text("Contact number"), footer: phoneSectionFooter) {
            TextField("Phone", text: $viewModel.formData.phoneNumber)
                .keyboardType(.phonePad)
                .foregroundStyle(viewModel.formData.price == 500 ? .gray : .primary)
                .opacity(viewModel.formData.price == 500 ? 0.8 : 1)
                .disabled(viewModel.formData.price == 500)
                .onChange(of: viewModel.formData.phoneNumber) { _, newValue in
                    viewModel.formData.phoneNumber = newValue.formattedPhoneNumber
                }
        }
    }
    
    private var phoneSectionFooter: some View {
        Text("Please enter a valid 11-digit phone number")
            .foregroundStyle(.red.gradient)
            .opacity(!viewModel.formData.phoneNumber.isValidPhoneNumber ? 1 : 0)
            .opacity(viewModel.formData.price == 500 ? 0 : 1)
    }

    private var descriptionSection: some View {
        Section {
            TextEditor(text: $viewModel.formData.description)
                .frame(height: 200)
                .characterLimit($viewModel.formData.description, limit: 500)
        } header: {
            HStack{
                Text("Description (keep it simple)")
                Spacer()
                Button("Clear text", action: { viewModel.formData.clearDescription() })
                    .foregroundStyle(viewModel.formData.description.isEmpty ? .gray : .red)
                    .font(.caption2)
                    .disabled(viewModel.formData.description.isEmpty)
            }
            
        } footer: {
            Text("\(viewModel.formData.description.count)/500")
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

    private var createButtonSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.createListing()
                }
            } label: {
                Text("Create listing")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!viewModel.isFormValid())
        }
    }
    
    // MARK: - Feature Sections
    
    private var homeChargingTime: some View {
        Picker("Home", selection: $viewModel.formData.homeChargingTime) {
            ForEach(viewModel.dataLoader.homeChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
        .disabled(viewModel.formData.price <= 500)
    }
    
    private var publicChargingTime: some View {
        Picker("Public", selection: $viewModel.formData.publicChargingTime) {
            ForEach(viewModel.dataLoader.publicChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
        .disabled(viewModel.formData.homeChargingTime == "Select")
    }
    
    private var additionalDataSection: some View {
        Section {
            Picker("Power BHP", selection: $viewModel.formData.powerBhp) {
                ForEach(viewModel.dataLoader.powerBhpOptions, id: \.self) { power in
                    Text(power).tag(power)
                }
            }
            .disabled(viewModel.formData.publicChargingTime == "Select")
            
            Picker("Battery capacity", selection: $viewModel.formData.batteryCapacity) {
                ForEach(viewModel.dataLoader.batteryCapacityOptions, id: \.self) { battery in
                    Text(battery).tag(battery)
                }
            }
            .disabled(viewModel.formData.powerBhp == "Select")
            
            Picker("Regen braking", selection: $viewModel.formData.regenBraking) {
                ForEach(viewModel.dataLoader.regenBrakingOptions, id: \.self) { regen in
                    Text(regen).tag(regen)
                }
            }
            .disabled(viewModel.formData.batteryCapacity == "Select")
            
            Picker("Warranty", selection: $viewModel.formData.warranty) {
                ForEach(viewModel.dataLoader.warrantyOptions, id: \.self) { warranty in
                    Text(warranty).tag(warranty)
                }
            }
            .disabled(viewModel.formData.regenBraking == "Select")
            
            Picker("Service history", selection: $viewModel.formData.serviceHistory) {
                ForEach(viewModel.dataLoader.serviceHistoryOptions, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            .disabled(viewModel.formData.warranty == "Select")
            
            Picker("Owners", selection: $viewModel.formData.numberOfOwners) {
                ForEach(viewModel.dataLoader.numberOfOwnersOptions, id: \.self) { owners in
                    Text(owners).tag(owners)
                }
            }
            .disabled(viewModel.formData.serviceHistory == "Select" && viewModel.formData.numberOfOwners == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    // MARK: - Promote listing (via StoreKit2)
    private var paymentSection: some View {
        StoreKitView(isPromoted: $viewModel.formData.isPromoted) {
            viewModel.formData.isPromoted = true
        }
    }

    // MARK: - Toolbar
    
    private var topBarLeadingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel", action: viewModel.resetFormDataAndState)
        }
    }
    
    private var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer(minLength: 0)
            Button { hideKeyboard() } label: { Text("Done") }
        }
    }
    
    private var topBarTrailingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                ImagePickerGridView(viewModel: viewModel.imageManager)
            } label: {
                ImageCounterView(count: viewModel.imageManager.totalImageCount)
            }
        }
    }
}








