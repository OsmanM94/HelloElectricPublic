//
//  EditListingView.swift
//  Clin
//
//  Created by asia on 27/07/2024.
//

import SwiftUI

struct ListingFormEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ListingFormEditViewModel()
        
    @State var listing: Listing

    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.viewState {
                    case .idle:
                        ListingFormEditSubview(viewModel: viewModel, listing: listing)
                        
                    case .loading:
                        CustomProgressView()
                        
                    case .uploading:
                        CustomProgressViewBar(progress: viewModel.uploadingProgress)
                        
                    case .success(let message):
                        SuccessView(message: message, doneAction: { viewModel.resetState(); dismiss() })
                        
                    case .error(let message):
                        ErrorView(message: message, retryAction: { viewModel.resetState() })
                    }
                }
            }
            .navigationTitle("Edit Listing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await viewModel.loadProhibitedWords() }
    }
}

#Preview {
    ListingFormEditView(listing: Listing.sampleData[0])
}

fileprivate struct ListingFormEditSubview: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var viewModel: ListingFormEditViewModel
    @State var listing: Listing
    
    var body: some View {
        Form {
            Section(header: Text("\(viewModel.imageSelections.count)/10")) {
                switch viewModel.imageLoadingState {
                case .idle:
                    EmptyContentView(message: "No selected photos", systemImage: "tray.fill")
                case .loading:
                    ImageLoadingPlaceHolders(viewModel: viewModel)
                case .deleting:
                    ImageLoadingPlaceHolders(viewModel: viewModel)
                case .loaded:
                    SelectedPhotosView(viewModel: viewModel)
                }
            }
            Section {
                TextField("What model is your EV?", text: $listing.model)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .characterLimit($listing.model, limit: 30)
            } header: {
                Text("Model")
            } footer: {
                Text("\(listing.model.count)/30")
            }
            
            Section("Condition") {
                Picker("Vehicle condition", selection: $listing.condition) {
                    ForEach(viewModel.vehicleCondition, id: \.self) { condition in
                        Text(condition).tag(condition)
                    }
                }
            }
            
            Section("Mileage") {
                TextField("Current mileage", value: $listing.mileage, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            Section("Year of manufacture") {
                Picker("\(listing.yearOfManufacture)", selection: $listing.yearOfManufacture) {
                    ForEach(viewModel.yearsOfmanufacture, id: \.self) { year in
                        Text(year).tag(year)
                    }
                }
            }
            
            Section("Average Range") {
                TextField("What is the average range?", text: $listing.range)
                    .keyboardType(.decimalPad)
                    .characterLimit($listing.range, limit: 4)
            }
            
            Section("Price") {
                TextField("Asking price", value: $listing.price, format: .currency(code: "GBP"))
                    .keyboardType(.decimalPad)
            }
            
            Section {
                TextEditor(text: $listing.description)
                    .frame(minHeight: 150)
                    .characterLimit($listing.description, limit: 500)
            } header: {
                Text("Description")
            } footer: {
                Text("\(listing.description.count)/500")
            }
            
            Section("Features") {
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
            Section {
                Button {
                    Task {
                        await viewModel.updateUserListing(listing)
                    }
                } label: {
                    Text("Update")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.yellow)
            }
            Section {
                Button(role: .destructive) {
                    viewModel.showDeleteAlert.toggle()
                } label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                }
                .deleteAlert(
                    isPresented: $viewModel.showDeleteAlert,
                    itemToDelete: .constant(listing)
                ) { listingToDelete in
                    await viewModel.deleteUserListing(listingToDelete)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button { dismiss() } label: { Text("Cancel") }
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
                    icon: "camera",
                    size: 20,
                    colour: .accentColor,
                    onSelect: { newItems in
                        viewModel.pickedImages.removeAll()
                        Task { for item in newItems {
                            await viewModel.loadItem(item: item)
                          }
                        }
                    })
                .deleteAlert(
                    isPresented: $viewModel.showDeleteAlert,
                    itemToDelete: $viewModel.imageToDelete
                ) { imageToDelete in
                    await viewModel.deleteImage(imageToDelete)
                }
            }
        }
    }
}

fileprivate struct ImageLoadingPlaceHolders: View {
    @Bindable var viewModel: ListingFormEditViewModel
    
    var body: some View {
        ScrollView(.horizontal)  {
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
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

fileprivate struct SelectedPhotosView: View {
    @Bindable var viewModel: ListingFormEditViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(viewModel.pickedImages, id: \.self) { pickedImage in
                    if let uiImage = UIImage(data: pickedImage.data) {
                        LoadedImageCell(action: {
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
