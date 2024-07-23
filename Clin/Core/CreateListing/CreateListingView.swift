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
                VStack {
                    switch viewModel.viewState {
                    case .idle:
                        Form {
                            Image(decorative: "ev3")
                                .resizable()
                                .scaledToFit()
                            
                            Section("UK Registration") {
                                TextField("Enter registration", text: $viewModel.registrationNumber)
                                    .fontWeight(.bold)
                                    .listRowBackground(Color.yellow)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                            }
                            Button {
                                Task {
                                    await viewModel.sendDvlaRequest()
                                }
                            } label: {
                                Text("Continue")
                                    .font(.headline)
                            }
                            .disabled(viewModel.registrationNumber.isEmpty)
                        }
                        
                    case .loading:
                        CustomProgressView()
                        
                    case .loaded:
                        Form {
                            Section(header: Text("\(viewModel.imageSelections.count)/20")) {
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
                            
                            Section("Optionals") {
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
                                            .characterLimit($viewModel.batteryCapacity, limit: 10)
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
                                            .characterLimit($viewModel.model, limit: 10)
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
                            ToolbarItem(placement: .topBarLeading) {
                                PhotosPicker(selection: $viewModel.imageSelections, maxSelectionCount: 20, selectionBehavior: .ordered ,matching: .any(of: [.images, .screenshots]), photoLibrary: .shared()) {
                                    Image(systemName: "camera")
                                        .symbolRenderingMode(.multicolor)
                                        .font(.system(size: 20))
                                }
                                .onChange(of: viewModel.imageSelections) { _, newItems in
                                    viewModel.imageSelections = newItems
                                    viewModel.loadTransferable(from: newItems)
                                }
                                .deleteAlert(
                                    isPresented: $viewModel.showDeleteAlert,
                                    imageToDelete: $viewModel.imageToDelete,
                                    deleteAction: viewModel.deleteImage
                                )
                            }
                        }
                        
                    case .success(let message):
                        ContentUnavailableView {
                            Image("ev2")
                                .resizable()
                                .scaledToFit()
                            Text(message)
                                .foregroundStyle(.green)
                                .fontWeight(.bold)
                        } description: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                        } actions: {
                            Button("Go back") { viewModel.resetState() }
                        }
                        
                    case .error(let message):
                        ContentUnavailableView {
                            Label {
                                Text(message)
                                    .foregroundColor(.red)
                            } icon: {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.red)
                            }
                        } description: {
                            Text("")
                        } actions: {
                            Button("Try again") { viewModel.resetState() }
                        }
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

struct NoPhotosView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No selected photos", systemImage: "tray.fill")
        }
    }
}

struct SelectedPhotosView: View {
    var viewModel: CreateListingViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.pickedImages, id: \.self) { pickedImage in
                    if let uiImage = UIImage(data: pickedImage.data) {
                        PhotosPickerCell(action: {
                            viewModel.imageToDelete = pickedImage
                            viewModel.showDeleteAlert.toggle()
                        }, image: uiImage)
                    }
                }
            }
            .padding([.top, .bottom])
        }
        .scrollIndicators(.hidden)
    }
}

struct ImageLoadingPlaceHolders: View {
    var viewModel: CreateListingViewModel
    
    var body: some View {
        HStack {
            ForEach(viewModel.imageSelections, id: \.self) { _ in
                Rectangle()
                    .foregroundStyle(.gray.opacity(0.5))
                    .frame(width: 100, height: 100)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .redacted(reason: .placeholder)
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                    .padding([.top, .bottom])
            }
        }
    }
}



