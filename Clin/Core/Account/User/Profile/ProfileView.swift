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
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .idle:
                        ProfileSubview(viewModel: viewModel)
                    
                    case .loading:
                        ProgressView("Analyzing...").scaleEffect(1.5)
                        
                    case .error(let message):
                        ErrorView(message: message, retryAction: {
                            viewModel.resetState()
                        })
                        
                    case .success(let message):
                        SuccessView(message: message, doneAction: {
                            viewModel.resetState()
                        })
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { viewModel.resetState() }
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

private struct ProfileSubview: View {
    @Bindable var viewModel: ProfileViewModel
    
    var body: some View {
        Form {
            Section {
                HStack(spacing: 0) {
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
                    
                    Spacer(minLength: 0)
                    
                    PhotosPickerView(
                        selections: $viewModel.imageSelection,
                        maxSelectionCount: 1,
                        selectionBehavior: .default,
                        icon: "pencil.circle.fill",
                        size: 30,
                        colour: .green,
                        onSelect: { newItems in
                            if let newValue = newItems.first {
                                Task {
                                    await viewModel.loadItem(item: newValue)
                                }
                            }
                        })
                    
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
    }
}
