//
//  UploadListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI

struct CreateFormView: View {
    @State private var viewModel: CreateFormViewModel
    
    init(viewModel: @autoclosure @escaping () -> CreateFormViewModel) {
        self._viewModel = State(wrappedValue: viewModel())
    }
  
    var body: some View {
        NavigationStack {
            Group {
                VStack(spacing: 0) {
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
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadProhibitedWords()
            await viewModel.fetchMakeAndModels()
        }
    }
}

#Preview {
    CreateFormView(viewModel: CreateFormViewModel(listingService: MockListingService(), imageManager: ImageManager(), prohibitedWordsService: ProhibitedWordsService()))
}

#Preview("Loaded") {
    NavigationStack {
        CreateFormSubview(viewModel: CreateFormViewModel(listingService: MockListingService(), imageManager: ImageManager(), prohibitedWordsService: ProhibitedWordsService()))
    }
}

fileprivate struct DvlaCheckView: View {
    @Binding var registrationNumber: String
    var sendDvlaRequest: () async -> Void
    
    var body: some View {
        Form {
            Section("UK Registration") {
                TextField("", text: $registrationNumber, prompt: Text("Enter registration").foregroundStyle(.gray))
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
            }
            .disabled(registrationNumber.isEmpty)
            .frame(maxWidth: .infinity)
        }
    }
}

fileprivate struct CreateFormSubview: View {
    @Bindable var viewModel: CreateFormViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Make")) {
                Picker("Select Make", selection: $viewModel.make) {
                    ForEach(viewModel.carMakes, id: \.make) { carMake in
                        Text(carMake.make).tag(carMake.make)
                    }
                }
                .onChange(of: viewModel.make) { 
                    viewModel.updateAvailableModels()
                }
            }
            
            Section(header: Text("Model")) {
                Picker("Select Model", selection: $viewModel.model) {
                    ForEach(viewModel.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
            }
            
            Section("Condition") {
                Picker("Vehicle condition", selection: $viewModel.condition) {
                    ForEach(viewModel.vehicleCondition, id: \.self) { condition in
                        Text(condition).tag(condition)
                    }
                }
            }
            
            Section("Mileage") {
                TextField("Current mileage", value: $viewModel.mileage, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            Section("Colour") {
                TextField("", text: $viewModel.colour)
                    .textInputAutocapitalization(.sentences)
                    .disabled(true)
            }
            
            Section("Year of manufacture") {
                Picker("\(viewModel.yearOfManufacture)", selection: $viewModel.yearOfManufacture) {
                    ForEach(viewModel.yearsOfmanufacture, id: \.self) { year in
                        Text(year).tag(year)
                    }
                }
            }
            
            Section("Average Range") {
                TextField("What is the average range?", text: $viewModel.range)
                    .keyboardType(.decimalPad)
                    .characterLimit($viewModel.range, limit: 4)
            }

            Section("Price") {
                TextField("Asking price", value: $viewModel.price, format: .currency(code: "GBP").precision(.fractionLength(0)))
                    .keyboardType(.decimalPad)
            }

            Section {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 150)
                    .characterLimit($viewModel.description, limit: 500)
            } header: {
                Text("Description")
            } footer: {
                Text("\(viewModel.description.count)/500")
            }
            
            Section("Features") {
                DisclosureGroup {
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
                } label: {
                    Label("Charging times", systemImage: "ev.charger")
                }
                
                DisclosureGroup {
                    HStack {
                        Text("kWh:")
                        TextField("", text: $viewModel.batteryCapacity)
                            .characterLimit($viewModel.batteryCapacity, limit: 5)
                            .keyboardType(.decimalPad)
                    }
                } label: {
                    Label("Battery capacity", systemImage: "battery.100percent.bolt")
                }
                
                DisclosureGroup {
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
                } label: {
                    Label("Additional data", systemImage: "gear")
                }
            }
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: viewModel.resetState)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer(minLength: 0)
                Button { hideKeyboard() } label: { Text("Done") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ImagePickerGridView(viewModel: viewModel)
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


