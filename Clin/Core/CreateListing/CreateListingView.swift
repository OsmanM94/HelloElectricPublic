//
//  UploadListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI

struct CreateListingView: View {
    
    @State private var viewModel = CreateListingViewModel()
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.viewState {
                    case .idle:
                        Form {
                            Section("Registration") {
                                TextField("Enter registration", text: $viewModel.registrationNumber)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                            }
                            Button {
                                Task {
                                    await viewModel.sendRequest()
                                }
                            } label: {
                                Text("Check")
                            }
                            .disabled(viewModel.registrationNumber.isEmpty)
                        }
                        
                    case .loading:
                        Button(action: {}) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .frame(width: 45, height: 45)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 15))
                        
                    case .loaded:
                        Form {
                            Section("Images") {
                                HStack {
                                    
                                }
                                .frame(height: 200)
                            }
                        
                            Section {
                                TextField("What make is your EV?", text: $viewModel.make)
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)
                                    .characterLimit($viewModel.make, limit: 30)
                            } header: {
                                Text("Make")
                            } footer: {
                                Text("\(viewModel.make.count)/30")
                            }
                            
                            Section {
                                TextField("What model?", text: $viewModel.model)
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)
                                    .characterLimit($viewModel.model, limit: 30)
                            } header: {
                                Text("Model")
                            } footer: {
                                Text("\(viewModel.model.count)/30")
                            }
                            
                            Section("Mileage") {
                                TextField("Current mileage", value: $viewModel.mileage, format: .number)
                                    .keyboardType(.decimalPad)
                            }
                            
                            Section("Year of manufacture") {
                                Picker("What year?", selection: $viewModel.yearOfManufacture) {
                                    ForEach(viewModel.yearsOfmanufacture, id: \.self) { year in
                                        Text(year).tag(year)
                                    }
                                }
                            }
                            
                            Section("Range") {
                                TextField("What is the average range?", text: $viewModel.range)
                                    .keyboardType(.decimalPad)
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
                                DisclosureGroup("Extra features") {
                                    
                                }
                            }
                            
                            Button {
                                Task {
                                    await viewModel.createListing()
                                }
                            } label: {
                                Text("Submit")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .listRowBackground(Color.green)
                            .disabled(viewModel.viewState == .loading)
                        }
                        .toolbar {
                            ToolbarItem {
                                Button("Cancel", action: viewModel.resetState)
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
                        
                        Spacer(minLength: 250)
                        
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
                            Text("Please try again.")
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
