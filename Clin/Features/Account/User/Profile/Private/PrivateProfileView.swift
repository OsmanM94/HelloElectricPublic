//
//  ProfileView.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//
import SwiftUI

struct PrivateProfileView: View {
    @State private var viewModel = PrivateProfileViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .idle:
                    ProfileSubview(viewModel: viewModel)
                    
                case .loading:
                    ProgressView("Analyzing...").scaleEffect(1.5)
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.resetState()
                    })
                    
                case .sensitiveApiNotEnabled:
                    SensitiveAnalysisErrorView(retryAction: {
                        viewModel.resetState()
                    })
                    
                case .success(let message):
                    SuccessView(message: message, doneAction: {
                        viewModel.resetState()
                    })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { viewModel.resetState() }
        }
        .task {
            await viewModel.loadPrivateProfile()
            await viewModel.loadProhibitedWords()
        }
    }
}

#Preview {
    PrivateProfileView()
        .environment(AuthViewModel())
}

 struct ProfileSubview: View {
    @Bindable var viewModel: PrivateProfileViewModel
    
    var body: some View {
        Form {
            avatarSection
            usernameSection
            updateButtonSection
        }
    }
    
    // MARK: - Sections
    
    var avatarSection: some View {
        Section {
            HStack {
                profileHeader
                Spacer()
                photoPicker
            }
        }
    }
    
    private var usernameSection: some View {
        Section(footer: Text("Must be between 3-20 characters")) {
            TextField("Username", text: $viewModel.username)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
        }
    }
    
    private var updateButtonSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.updateProfileButtonTapped()
                    await viewModel.loadPrivateProfile()
                }
            } label: {
                Text("Update profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isInteractionBlocked)
        }
    }
    
    // MARK: - UI Components
     
     private var profileHeader: some View {
         HStack {
             ZStack {
                 if let avatarImage = viewModel.avatarImage {
                     avatarImage.image.resizable()
                 } else {
                     CircularProfileView(size: .xLarge, profile: viewModel.profile)
                 }
             }
             .scaledToFill()
             .clipShape(Circle())
             .frame(width: 80, height: 80)
             
             Text("\(viewModel.displayName)")
                 .font(.title3)
                 .fontWeight(.semibold)
                 .padding(.leading)
         }
     }
     
    private var photoPicker: some View {
        SinglePhotoPicker(
            selection: $viewModel.imageSelection,
            photoLibrary: .shared()
        ) {
            Image(systemName: "pencil.circle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 30))
                .foregroundStyle(.accent)
        } onSelect: { newPhoto in
            if let newPhoto = newPhoto {
                Task {
                    await viewModel.loadItem(item: newPhoto)
                }
            }
        }
    }
}

