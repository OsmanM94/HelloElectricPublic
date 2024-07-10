//
//  ProfileView.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @State private var viewModel = ProfileViewModel()
   
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.profileViewState {
                    case .idle:
                        Form {
                            Section {
                                HStack {
                                    Group {
                                        ZStack {
                                            if let avatarImage = viewModel.avatarImage {
                                                avatarImage.image.resizable()
                                            } else {
                                                CircularProfileView(size: .xLarge, profile: viewModel.profile)
                                            }
                                        }
                                    }
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 80, height: 80)
                                    
                                    Text("\(viewModel.displayName)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .padding(.leading)
                                    
                                    Spacer()
                                    
                                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                                        Image(systemName: "pencil.circle.fill")
                                            .symbolRenderingMode(.multicolor)
                                            .font(.system(size: 30))
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                            
                            Section(footer: Text("Must be between 3-20 characters")) {
                                TextField("Username", text: $viewModel.username)
                                    .textContentType(.username)
                                    .textInputAutocapitalization(.never)
                                    .submitLabel(.done)
                            }
                            
                            Section {
                                Button {
                                    Task {
                                    await viewModel.updateProfileButtonTapped()
                                    await viewModel.getInitialProfile()
                                    }
                                } label: {
                                     if viewModel.cooldownTime > 0  {
                                        Text("Please wait \(viewModel.cooldownTime) seconds to update again")
                                            .monospacedDigit()
                                            .foregroundStyle(.gray)
                                    } else {
                                        Text("Update profile")
                                            .fontWeight(.bold)
                                            .foregroundStyle(viewModel.validateUsername ? .green : .gray.opacity(0.5))
                                    }
                                }
                                .disabled(viewModel.isInteractionBlocked)
                            }
                        }
                        .onChange(of: viewModel.imageSelection) { _, newValue in
                            guard let newValue = newValue else { return }
                            viewModel.loadTransferable(from: newValue)
                        }
                        
                    case .loading:
                        ProgressView("Analyzing...")
                            .scaleEffect(1.5)
                        
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
                        
                    case .success(let message):
                        ContentUnavailableView {
                            Label {
                                Text(message)
                                    .foregroundColor(.green)
                            } icon: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        } description: {
                            Text("")
                        } actions: {
                            Button("Go back") { viewModel.resetState() }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                viewModel.resetState()
            }
        }
        .task {
            await viewModel.getInitialProfile()
            await viewModel.loadProhibitedWords()
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
}

