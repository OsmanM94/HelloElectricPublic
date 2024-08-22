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
            Group {
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
                            .task {
                                await viewModel.loadBulkData()
                            }
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
            }
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
                    .submitLabel(.done)
                    .listRowBackground(Color.yellow)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .foregroundStyle(.green)
                            .frame(width: 35)
                            .scaledToFill()
                            .offset(x: -20, y: 0)
                    }
            }
            
            Button {
                Task {
                    await sendDvlaRequest()
                }
            } label: {
                Text("Continue")
                    .foregroundStyle(registrationNumber.isEmpty ? .gray.opacity(0.5) : .white)
                    .fontWeight(.bold)
                    .animation(.easeInOut, value: registrationNumber)
            }
            .disabled(registrationNumber.isEmpty)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color(registrationNumber.isEmpty ? .gray.opacity(0.2) : .accent))
            
        }
    }
}

fileprivate struct CreateFormSubview: View {
    @Bindable var viewModel: CreateFormViewModel
    
    var body: some View {
        Form {
            makeSection
            modelSection
            conditionSection
            mileageSection
            colourSection
            yearOfManufactureSection
            rangeSection
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
    
    // MARK: - Sections
    
    private var makeSection: some View {
        Section(header: Text("Make")) {
            if viewModel.isLoadingMake {
                ProgressView()
            } else {
                Picker("Select Make", selection: $viewModel.make) {
                    ForEach(viewModel.evSpecific, id: \.make) { item in
                        Text(item.make).tag(item.make)
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: viewModel.make) {
                    viewModel.updateAvailableModels()
                }
            }
        }
    }
    
    private var modelSection: some View {
        Section(header: Text("Model")) {
            if viewModel.isLoadingMake {
                ProgressView()
            } else {
                Picker("Select Model", selection: $viewModel.model) {
                    ForEach(viewModel.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
    }
    
    private var conditionSection: some View {
        Section("Condition") {
            Picker("Vehicle condition", selection: $viewModel.condition) {
                ForEach(viewModel.vehicleCondition, id: \.self) { condition in
                    Text(condition).tag(condition)
                }
            }
        }
    }
    
    private var mileageSection: some View {
        Section("Mileage") {
            TextField("Current mileage", value: $viewModel.mileage, format: .number)
                .keyboardType(.decimalPad)
        }
    }
    
    private var colourSection: some View {
        Section("Colour") {
            TextField("Colour", text: $viewModel.colour)
                .textInputAutocapitalization(.sentences)
                .disabled(true)
        }
    }
    
    private var yearOfManufactureSection: some View {
        Section("Year of manufacture") {
            Picker("Selected Year", selection: $viewModel.selectedYear) {
                ForEach(viewModel.yearOfManufacture, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
        }
    }
    
    private var rangeSection: some View {
        Section("Average Range") {
            TextField("What is the average range?", text: $viewModel.range)
                .keyboardType(.decimalPad)
                .characterLimit($viewModel.range, limit: 4)
        }
    }

    private var priceSection: some View {
        Section("Price") {
            TextField("Asking price", value: $viewModel.price, format: .currency(code: "GBP").precision(.fractionLength(0)))
                .keyboardType(.decimalPad)
        }
    }

    private var descriptionSection: some View {
        Section {
            TextEditor(text: $viewModel.description)
                .frame(minHeight: 150)
                .characterLimit($viewModel.description, limit: 500)
        } header: {
            Text("Description")
        } footer: {
            Text("\(viewModel.description.count)/500")
        }
    }
    
    private var featuresSection: some View {
        Section("Features") {
            DisclosureGroup {
                chargingTimesSection
            } label: {
                Label("Charging times", systemImage: "ev.charger")
            }
            
            DisclosureGroup {
                batteryCapacitySection
            } label: {
                Label("Battery capacity", systemImage: "battery.100percent.bolt")
            }
            
            DisclosureGroup {
                additionalDataSection
            } label: {
                Label("Additional data", systemImage: "gear")
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
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.green)
        }
    }
    
    // MARK: - Feature Sections
    
    private var chargingTimesSection: some View {
        VStack {
            HStack {
                Text("H:")
                TextField("Estimated home time charging", text: $viewModel.homeChargingTime)
                    .characterLimit($viewModel.homeChargingTime, limit: 30)
            }
            HStack {
                Text("P:")
                TextField("Estimated public time charging", text: $viewModel.publicChargingTime)
                    .characterLimit($viewModel.publicChargingTime, limit: 30)
            }
        }
    }
    
    private var batteryCapacitySection: some View {
        HStack {
            Text("kWh:")
            TextField("", text: $viewModel.batteryCapacity)
                .characterLimit($viewModel.batteryCapacity, limit: 5)
                .keyboardType(.decimalPad)
        }
    }
    
    private var additionalDataSection: some View {
        VStack {
            HStack {
                Text("BHP:")
                TextField("What is the bhp power?", text: $viewModel.powerBhp)
                    .keyboardType(.decimalPad)
                    .characterLimit($viewModel.powerBhp, limit: 5)
            }
            Picker("Regen braking", selection: $viewModel.regenBraking) {
                ForEach(viewModel.vehicleRegenBraking, id: \.self) { regen in
                    Text(regen).tag(regen)
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
            Picker("How many owners?", selection: $viewModel.numberOfOwners) {
                ForEach(viewModel.vehicleNumberOfOwners, id: \.self) { owners in
                    Text(owners).tag(owners)
                }
            }
        }
    }
}









