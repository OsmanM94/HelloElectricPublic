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
                    CircularProgressBar(progress: viewModel.uploadingProgress)
                    
                case .success(let message):
                    SuccessView(message: message, doneAction: { viewModel.resetState() })
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.resetState()
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

fileprivate struct DvlaCheckView: View {
    @Binding var registrationNumber: String
    var sendDvlaRequest: () async -> Void
    
    var body: some View {
        Form {
            Section("UK Registration") {
                TextField("", text: $registrationNumber, prompt: Text("Enter registration").foregroundStyle(.black.opacity(0.3)))
                    .foregroundStyle(.black)
                    .font(.system(size: 24, weight: .semibold))
                    .submitLabel(.go)
                    .listRowBackground(Color.yellow.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .foregroundStyle(.green.opacity(0.8))
                            .frame(width: 35)
                            .scaledToFill()
                            .offset(x: -20, y: 0)
                    }
                    .onSubmit {
                        Task {
                            guard !registrationNumber.isEmpty else { return }
                            await sendDvlaRequest()
                        }
                    }
            }
        }
    }
}

fileprivate struct CreateFormSubview: View {
    @Bindable var viewModel: CreateFormViewModel
    
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
                    mileageLocationSection
                    colourRangeSection
                    priceSection
                    descriptionSection
                    featuresSection
                    createButtonSection
                }
                .toolbar {
                    topBarLeadingToolbarContent
                    keyboardToolbarContent
                    topBarTrailingToolbarContent
                }
            case .error(let message):
                ErrorView(message: message) { viewModel.resetState() }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.subFormViewState)
    }
    
    // MARK: - Sections
    
    private var makeModelSection: some View {
        Section(header: Text("Make and model "), footer: Text("Selected make and model cannot be changed later.")) {
            Picker("Make", selection: $viewModel.make) {
                ForEach(viewModel.makeOptions, id: \.self) { make in
                    Text(make).tag(make)
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
            .disabled(viewModel.make == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    private var bodyTypeSection: some View {
        Section("Body Type") {
            Picker("Body", systemImage: "car.fill", selection: $viewModel.body) {
                ForEach(viewModel.bodyTypeOptions, id: \.self) { body in
                    Text(body).tag(body)
                }
            }
            .disabled(viewModel.make == "Select" || viewModel.model == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    private var yearConditionSection: some View {
        Section(header: Text("Year and condition")) {
            Picker("Year of manufacture", systemImage: "licenseplate.fill", selection: $viewModel.selectedYear) {
                ForEach(viewModel.yearOptions, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            .disabled(viewModel.body == "Select")
            
            Picker("Condition", systemImage: "axle.2", selection: $viewModel.condition) {
                ForEach(viewModel.conditionOptions, id: \.self) { condition in
                    Text(condition).tag(condition)
                }
            }
            .disabled(viewModel.selectedYear == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    private var mileageLocationSection: some View {
        Section("Mileage and location") {
            HStack(spacing: 15) {
                Image(systemName: "gauge.with.needle")
                    .imageScale(.large)
                    .foregroundStyle(viewModel.condition == "Select" ? .green.opacity(0.5) : .green)
                TextField("Current mileage", value: $viewModel.mileage, format: .number)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(viewModel.condition == "Select" ? .gray : .primary)
                    .opacity(viewModel.condition == "Select" ? 0.8 : 1)
            }
            .disabled(viewModel.condition == "Select")
            
            Picker("Location", systemImage: "location.fill.viewfinder", selection: $viewModel.location) {
                ForEach(viewModel.availableLocations, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.navigationLink)
            .disabled(viewModel.mileage == 500)
        }
    }

    private var colourRangeSection: some View {
        Section("Colour and range") {
            Picker("Colour", systemImage: "paintpalette.fill" ,selection: $viewModel.colour) {
                ForEach(viewModel.colourOptions, id: \.self) { colour in
                    Text(colour).tag(colour)
                }
            }
            .disabled(viewModel.location == "Select")
            
            Picker("Driving range", systemImage: "road.lanes", selection: $viewModel.range) {
                ForEach(viewModel.rangeOptions, id: \.self) { range in
                    Text(range).tag(range)
                }
            }
            .disabled(viewModel.colour == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    private var priceSection: some View {
        Section("Price") {
            TextField("Asking price", value: $viewModel.price, format: .currency(code: "GBP").precision(.fractionLength(0)))
                .keyboardType(.decimalPad)
                .foregroundStyle(viewModel.range == "Select" ? .gray : .primary)
                .opacity(viewModel.range == "Select" ? 0.8 : 1)
                .disabled(viewModel.range == "Select")
            
        }
    }

    private var descriptionSection: some View {
        Section {
            TextEditor(text: $viewModel.description)
                .frame(height: 200)
                .characterLimit($viewModel.description, limit: 500)
        } header: {
            HStack{
                Text("Description (keep it simple)")
                Spacer()
                Button("Clear text", action: { viewModel.clearDescription() })
                    .foregroundStyle(viewModel.description.isEmpty ? .gray : .red)
                    .font(.caption2)
                    .disabled(viewModel.description.isEmpty)
            }
            
        } footer: {
            Text("\(viewModel.description.count)/500")
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
        Picker("Home", selection: $viewModel.homeChargingTime) {
            ForEach(viewModel.homeChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
        .disabled(viewModel.price <= 500)
    }
    
    private var publicChargingTime: some View {
        Picker("Public", selection: $viewModel.publicChargingTime) {
            ForEach(viewModel.publicChargingTimeOptions, id: \.self) { time in
                Text(time).tag(time)
            }
        }
        .pickerStyle(.navigationLink)
        .disabled(viewModel.homeChargingTime == "Select")
    }
    
    private var additionalDataSection: some View {
        Section {
            Picker("Power BHP", selection: $viewModel.powerBhp) {
                ForEach(viewModel.powerBhpOptions, id: \.self) { power in
                    Text(power).tag(power)
                }
            }
            .disabled(viewModel.publicChargingTime == "Select")
            
            Picker("Battery capacity", selection: $viewModel.batteryCapacity) {
                ForEach(viewModel.batteryCapacityOptions, id: \.self) { battery in
                    Text(battery).tag(battery)
                }
            }
            .disabled(viewModel.powerBhp == "Select")
            
            Picker("Regen braking", selection: $viewModel.regenBraking) {
                ForEach(viewModel.regenBrakingOptions, id: \.self) { regen in
                    Text(regen).tag(regen)
                }
            }
            .disabled(viewModel.batteryCapacity == "Select")
            
            Picker("Warranty", selection: $viewModel.warranty) {
                ForEach(viewModel.warrantyOptions, id: \.self) { warranty in
                    Text(warranty).tag(warranty)
                }
            }
            .disabled(viewModel.regenBraking == "Select")
            
            Picker("Service history", selection: $viewModel.serviceHistory) {
                ForEach(viewModel.serviceHistoryOptions, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            .disabled(viewModel.warranty == "Select")
            
            Picker("Owners", selection: $viewModel.numberOfOwners) {
                ForEach(viewModel.numberOfOwnersOptions, id: \.self) { owners in
                    Text(owners).tag(owners)
                }
            }
            .disabled(viewModel.serviceHistory == "Select" && viewModel.numberOfOwners == "Select")
        }
        .pickerStyle(.navigationLink)
    }
    
    // MARK: - Toolbar
    
    private var topBarLeadingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel", action: viewModel.resetState)
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
                ImagePickerGridView(viewModel: viewModel)
            } label: {
                ImageCounterView(count: viewModel.totalImageCount)
            }
        }
    }
}









