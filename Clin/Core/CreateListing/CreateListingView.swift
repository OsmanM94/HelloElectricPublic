//
//  UploadListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @State private var viewModel = CreateListingViewModel()
  
    var body: some View {
        NavigationStack {
            Group {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .idle:
                        IdleStateView(
                        registrationNumber: $viewModel.registrationNumber,
                        sendDvlaRequest: { await viewModel.sendDvlaRequest() })
                        
                    case .loading:
                        CustomProgressView()
                        
                    case .loaded:
                        LoadedCreateListingView(viewModel: viewModel)
                        
                    case .uploading:
                        CustomProgressViewBar(progress: viewModel.uploadingProgress)
                        
                    case .success(let message):
                        SuccessView(message: message, doneAction: { viewModel.resetState() })
  
                    case .error(let message):
                        ErrorView(message: message, retryAction: {
                            viewModel.resetState()
                        })
                    }
                }
            }
            .navigationTitle("Selling")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CreateListingView()
}

#Preview("Loaded") {
    let viewModel = CreateListingViewModel()
    NavigationStack {
        LoadedCreateListingView(viewModel: viewModel)
    }
}

private struct IdleStateView: View {
    @Binding var registrationNumber: String
    var sendDvlaRequest: () async -> Void
    
    var body: some View {
        Form {
            Section("UK Registration") {
                TextField("Enter registration", text: $registrationNumber)
                    .fontWeight(.bold)
                    .submitLabel(.done)
                    .listRowBackground(Color.yellow)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }
            Button {
                Task {
                    await sendDvlaRequest()
                }
            } label: {
                Text("Continue")
            }
            .disabled(registrationNumber.isEmpty)
        }
    }
}

private struct LoadedCreateListingView: View {
    @Bindable var viewModel: CreateListingViewModel
    
    var body: some View {
        Form {
            Section(header: Text("\(viewModel.imageSelections.count)/10")) {
                    switch viewModel.imageLoadingState {
                    case .idle:
                        NoPhotosView()
                    case .loading:
                        ImageLoadingPlaceHolders(viewModel: viewModel)
                    case .loaded:
                        SelectedPhotosView(viewModel: viewModel)
                    }
            }
            
            Section("Make") {
                TextField("", text: $viewModel.make)
                    .disabled(true)
            }
            
            Section {
                TextField("What model is your EV?", text: $viewModel.model)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .characterLimit($viewModel.model, limit: 30)
            } header: {
                Text("Model")
            } footer: {
                Text("\(viewModel.model.count)/30")
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
                    .textInputAutocapitalization(.words)
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
                TextField("Asking price", value: $viewModel.price, format: .currency(code: "GBP"))
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
            ToolbarItem {
                Button("Cancel", action: viewModel.resetState)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer(minLength: 0)
                Button { viewModel.hideKeyboard() } label: { Text("Done") }
            }
            ToolbarItem(placement: .topBarLeading) {
                PhotosPickerView(
                    selections: $viewModel.imageSelections,
                    maxSelectionCount: 10,
                    selectionBehavior: .ordered,
                    onSelect: { newItems in
                        viewModel.pickedImages.removeAll()
                        Task { for item in newItems {
                            await viewModel.loadItem(item: item)
                            }
                        }
                        viewModel.checkImageState()
                })
                .deleteAlert(isPresented: $viewModel.showDeleteAlert, imageToDelete: $viewModel.imageToDelete) { imageToDelete in
                     await viewModel.deleteImage(imageToDelete)
                }
            }
        }
    }
}

private struct NoPhotosView: View {
    var body: some View {
        EmptyContentView(message: "No selected photos", systemImage: "tray.fill")
    }
}

private struct SelectedPhotosView: View {
    var viewModel: CreateListingViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(viewModel.pickedImages, id: \.self) { pickedImage in
                    if let uiImage = UIImage(data: pickedImage.data) {
                        PhotosPickerCell(action: {
                            viewModel.imageToDelete = pickedImage
                            viewModel.showDeleteAlert.toggle()
                        }, image: uiImage)
                    }
                }
            }
            .padding(.all)
        }
        .scrollIndicators(.hidden)
    }
}

private struct ImageLoadingPlaceHolders: View {
    var viewModel: CreateListingViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(viewModel.imageSelections, id: \.self) { _ in
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .redacted(reason: .placeholder)
                        .overlay {
                            ProgressView()
                                .scaleEffect(1.2)
                        }
                }
            }
            .padding(.all)
        }
        .scrollIndicators(.hidden)
    }
}


