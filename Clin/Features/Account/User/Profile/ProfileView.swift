//
//  ProfileView.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//
import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .idle:
                    ProfileSubview(viewModel: viewModel)
                    
                case .loading:
                    CustomProgressView()
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.resetStateToIdle()
                    })
                    
                case .sensitiveApiNotEnabled:
                    SensitiveAnalysisErrorView(retryAction: {
                        viewModel.resetStateToIdle()
                    })
                    
                case .success(let message):
                    SuccessView(message: message, doneAction: {
                        viewModel.resetStateToIdle()
                    })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { viewModel.resetState() }
        }
        .task {
            await viewModel.loadProfile()
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
}

fileprivate struct ProfileSubview: View {
    @Bindable var viewModel: ProfileViewModel
    @State private var showDealerTermsAndConditions: Bool = false
    @FocusState private var focusedField: Field?
    
    @State private var originalUsername: String
    @State private var originalIsDealer: Bool
    @State private var originalAddress: String
    @State private var originalLocation: String
    @State private var originalPostcode: String
    @State private var originalWebsite: String
    @State private var originalCompanyNumber: String
    
    init(viewModel: ProfileViewModel) {
        self._viewModel = Bindable(viewModel)
        self._originalUsername = State(initialValue: viewModel.username)
        self._originalIsDealer = State(initialValue: viewModel.isDealer)
        self._originalAddress = State(initialValue: viewModel.address)
        self._originalLocation = State(initialValue: viewModel.location)
        self._originalPostcode = State(initialValue: viewModel.postcode)
        self._originalWebsite = State(initialValue: viewModel.website)
        self._originalCompanyNumber = State(initialValue: viewModel.companyNumber)
    }
    
    enum Field: Hashable {
        case address, city, postcode, website, companyNumber
    }
    
    var body: some View {
        Form {
            avatarSection
            usernameSection
            dealerSection
            updateButtonSection
        }
        .sheet(isPresented: $showDealerTermsAndConditions) {
            DealerTermsAndConditionsView()
        }
        .onAppear {
            updateOriginalValues()
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
            TextField("Public name", text: $viewModel.username)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
        }
    }
    
    private var dealerSection: some View {
        Section(header: Text("For dealers only")) {
            Toggle(isOn: $viewModel.isDealer.animation()) {
                Text("Dealer")
            }
            if viewModel.isDealer {
                VStack(alignment: .leading, spacing: 10) {
                    Text("By providing dealer information, you agree to our Terms and Conditions.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button("Terms and Conditions") {
                        showDealerTermsAndConditions.toggle()
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
                .padding(.vertical, 5)
                
                VStack(spacing: 15) {
                    HStack {
                        TextField("Address", text: $viewModel.address)
                            .focused($focusedField, equals: .address)
                            .characterLimit($viewModel.address, limit: 50)
                            .submitLabel(.next)
                            .textContentType(.fullStreetAddress)
                            .onSubmit { focusedField = .city }
                            .textInputAutocapitalization(.words)
                        validationIcon(isValid: viewModel.validateAddress)
                    }
                    
                    HStack {
                        TextField("City", text: $viewModel.location)
                            .focused($focusedField, equals: .city)
                            .characterLimit($viewModel.location, limit: 30)
                            .submitLabel(.next)
                            .textContentType(.addressCity)
                            .onSubmit { focusedField = .postcode }
                            .textInputAutocapitalization(.words)
                        validationIcon(isValid: viewModel.validateCity)
                    }
                    
                    HStack {
                        TextField("Postcode", text: $viewModel.postcode)
                            .focused($focusedField, equals: .postcode)
                            .characterLimit($viewModel.postcode, limit: 10)
                            .submitLabel(.next)
                            .textContentType(.postalCode)
                            .onSubmit { focusedField = .website }
                            .textInputAutocapitalization(.characters)
                        validationIcon(isValid: viewModel.validatePostCode)
                    }
                    
                    HStack {
                        TextField("Website", text: $viewModel.website)
                            .focused($focusedField, equals: .website)
                            .characterLimit($viewModel.website, limit: 50)
                            .submitLabel(.next)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .onSubmit { focusedField = .companyNumber }
                            .textInputAutocapitalization(.never)
                        Text("Optional")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        TextField("Company Number", text: $viewModel.companyNumber)
                            .focused($focusedField, equals: .companyNumber)
                            .characterLimit($viewModel.companyNumber, limit: 20)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                            .textInputAutocapitalization(.never)
                        validationIcon(isValid: viewModel.validateCompanyNumber)
                    }
                }
                .autocorrectionDisabled()
            }
        }
     }
     
     private var updateButtonSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.updateProfileButtonTapped()
                    await viewModel.loadProfile()
                    updateOriginalValues()
                }
            } label: {
                Text("Update profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!hasChanges || viewModel.isInteractionBlocked)
        }
    }
    
    // MARK: - Tracks profile changes and update only if necessary
    private var hasChanges: Bool {
        viewModel.username != originalUsername ||
        viewModel.isDealer != originalIsDealer ||
        viewModel.address != originalAddress ||
        viewModel.location != originalLocation ||
        viewModel.postcode != originalPostcode ||
        viewModel.website != originalWebsite ||
        viewModel.companyNumber != originalCompanyNumber ||
        viewModel.avatarImage != nil
    }
    
    private func updateOriginalValues() {
        originalUsername = viewModel.username
        originalIsDealer = viewModel.isDealer
        originalAddress = viewModel.address
        originalLocation = viewModel.location
        originalPostcode = viewModel.postcode
        originalWebsite = viewModel.website
        originalCompanyNumber = viewModel.companyNumber
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
        .buttonStyle(.plain)
    }
}
