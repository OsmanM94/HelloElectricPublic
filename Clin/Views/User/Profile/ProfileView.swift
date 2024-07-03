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
                
                Section {
                    TextField("Username", text: $viewModel.username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            Task {
                                await viewModel.getInitialProfile()
                            }
                        }
                }
                
                Section {
                    Button {
                        Task {
                          await viewModel.updateProfileButtonTapped()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Update profile")
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .onChange(of: viewModel.imageSelection) { _, newValue in
                guard let newValue = newValue else { return }
                viewModel.loadTransferable(from: newValue)
            }
        }
        .task {
            await viewModel.getInitialProfile()
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
}

