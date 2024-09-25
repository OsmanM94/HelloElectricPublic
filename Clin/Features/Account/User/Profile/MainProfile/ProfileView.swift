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
                    CustomProgressView(message: "Loading profile...")
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        refreshMessage: "Try again",
                        retryAction: { viewModel.resetStateToIdle() },
                        systemImage: "xmark.circle.fill")
                    
                case .sensitiveApiNotEnabled:
                    SensitiveAnalysisErrorView(
                        retryAction: { viewModel.resetStateToIdle() })
                    
                case .success(let message):
                    SuccessView(
                        message: message,
                        doneAction: { viewModel.resetStateToIdle() })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { viewModel.resetState() }
        }
        .task { await viewModel.loadProfile() }
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
    
    @State private var originalUsername: String = ""
    @State private var originalAddress: String = ""
    @State private var originalLocation: String = ""
    @State private var originalPostcode: String = ""
    @State private var originalWebsite: String = ""
    @State private var originalCompanyNumber: String = ""
    
    @State private var isCompanyVerified: Bool = false
    
    init(viewModel: ProfileViewModel) {
        self._viewModel = Bindable(viewModel)
        updateOriginalValues()
    }
    
    enum Field: Hashable {
        case address, city, postcode, website, companyNumber
    }
    
    var body: some View {
        Form {
            avatarSection
            usernameSection
            dealerValidation
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
        Section(footer: Text("Must be between 3-30 characters")) {
            TextField("Change name", text: $viewModel.username)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .characterLimit($viewModel.username, limit: 30)
        }
    }
    
    private var dealerValidation: some View {
        Section(header: Text("Dealer Information")) {
            Toggle(isOn: $viewModel.isDealer.animation()) {
                Text("I am a dealer")
            }
            .onChange(of: viewModel.isDealer) { _, newValue in
                if newValue {
                    isCompanyVerified = false
                    viewModel.enableDealerStatus()
                } else {
                    viewModel.disableDealerStatus()
                    isCompanyVerified = false
                }
            }
            
            if viewModel.isDealer {
                VStack(spacing: 20) {
                    switch viewModel.companiesHouseViewState {
                    case .idle:
                        if !isCompanyVerified {
                            companyNumberInput
                        } else {
                            verifiedCompanyInfo
                        }
                        
                    case .success:
                        dealerInformationForm
                    }
                }
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .buttonStyle(.plain)
            }
        }
     }
    
    private var companyNumberInput: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Company number")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("Enter company number", text: $viewModel.getCompanyNumber)
                .autocorrectionDisabled()
                .submitLabel(.send)
                .onSubmit {
                    Task {
                        await viewModel.loadCompanyInfo()
                        isCompanyVerified = viewModel.companiesHouseViewState == .success
                    }
                }
                .padding(.top)
        }
    }
    
    private var verifiedCompanyInfo: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.tabColour)
            VStack(alignment: .leading) {
                Text(viewModel.displayName)
                    .font(.subheadline)
                Text("Status: Verified")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            Spacer()
            Button("Change") {
                isCompanyVerified = false
                viewModel.companiesHouseViewState = .idle
            }
            .font(.caption)
        }
        .padding()
    }

    private var dealerInformationForm: some View {
        VStack(spacing: 15) {
            termsAndConditionsSection
            
            Group {
                dealerTextField(
                    title: "Address",
                    text: $viewModel.address,
                    contentType: .fullStreetAddress,
                    field: .address,
                    validation: {
                        _ in viewModel.validateAddress
                    })
                dealerTextField(
                    title: "City",
                    text: $viewModel.location,
                    contentType: .addressCity,
                    field: .city,
                    validation: {
                        _ in viewModel.validateCity
                    })
                dealerTextField(
                    title: "Postcode",
                    text: $viewModel.postcode,
                    contentType: .postalCode,
                    field: .postcode,
                    validation: {
                        _ in viewModel.validatePostCode
                    })
                dealerTextField(
                    title: "Website (Optional)",
                    text: $viewModel.website,
                    contentType: .URL,
                    field: .website,
                    validation: {
                        _ in true
                    })
                dealerTextField(
                    title: "Company Number",
                    text: $viewModel.companyNumber,
                    contentType: nil,
                    field: .companyNumber,
                    validation: {
                        _ in viewModel.validateCompanyNumber
                    }).allowsHitTesting(false)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .buttonStyle(.plain)
        }
    }

    private func dealerTextField(title: String, text: Binding<String>, contentType: UITextContentType?, field: Field, validation: @escaping (String) -> Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                TextField(title, text: text)
                    .focused($focusedField, equals: field)
                    .textContentType(contentType)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                
                validationIcon(isValid: validation(text.wrappedValue))
            }
        }
    }

    private var termsAndConditionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("By providing dealer information, you agree to our Terms and Conditions.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button("Terms and Conditions") {
                showDealerTermsAndConditions.toggle()
            }
            .font(.footnote)
            .foregroundStyle(.blue)
        }
        .padding(.vertical, 5)
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
        viewModel.address != originalAddress ||
        viewModel.location != originalLocation ||
        viewModel.postcode != originalPostcode ||
        viewModel.website != originalWebsite ||
        viewModel.companyNumber != originalCompanyNumber ||
        viewModel.avatarImage != nil
    }
    
    private func updateOriginalValues() {
        originalUsername = viewModel.username
        originalAddress = viewModel.address
        originalLocation = viewModel.location
        originalPostcode = viewModel.postcode
        originalWebsite = viewModel.website
        originalCompanyNumber = viewModel.companyNumber
        isCompanyVerified = viewModel.isDealer
    }
    
    // MARK: - UI Components
     
     private var profileHeader: some View {
         HStack {
             ZStack {
                 switch viewModel.imageViewState {
                 case .idle, .success:
                     if let avatarImage = viewModel.avatarImage {
                         avatarImage.image.resizable()
                     } else {
                         CircularProfileView(size: .xLarge, profile: viewModel.profile)
                     }
                     
                 case .loading:
                     ProgressView()
                     
                 }
             }
             .scaledToFill()
             .clipShape(Circle())
             .frame(width: 80, height: 80)
             
             Text(viewModel.displayName)
                 .font(.headline)
                 .fontWeight(.semibold)
                 .fontDesign(.rounded)
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
                .foregroundStyle(.tabColour)
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
