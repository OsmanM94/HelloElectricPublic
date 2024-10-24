//
//  ProfileViewModel.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//
import SwiftUI
import PhotosUI
import Factory

@Observable
final class ProfileViewModel {
    // MARK: - Enums
    enum ViewState: Equatable {
        case idle
        case loading
        case error(String)
        case sensitiveApiNotEnabled
        case success(String)
    }
    
    enum CompaniesHouse {
        case idle
        case success
    }
    
    enum ImageViewState: Equatable {
        case idle
        case loading
        case success
    }
    
    // MARK: - Observable properties
    var imageSelection: PhotosPickerItem?
    private(set) var avatarImage: SelectedImage?
    private(set) var displayName: String = "Private Seller"
    private(set) var profile: Profile? = nil
    
    // ViewStates
    var viewState: ViewState = .loading
    var companiesHouseViewState: CompaniesHouse = .idle
    var imageViewState: ImageViewState = .idle
    
    var username: String = ""
    var isDealer: Bool = false
    var address: String = ""
    var location: String = ""
    var postcode: String = ""
    var companyNumber: String = ""
    var website: String = "https://"
    
    // Tracks if the profile was updated so we don't update Supabase redundant
    var isProfileUpdated: Bool = false
    
    // Companies house company checks
    var getCompanyNumber: String = ""

    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.prohibitedWordsService) private var prohibitedWordsService
    @ObservationIgnored @Injected(\.imageManager) private var imageManager
    @ObservationIgnored @Injected(\.profileService) private var profileService
    @ObservationIgnored @Injected(\.companiesHouse) private var companiesHouseService
    
    // MARK: - Main actor functions
    
    @MainActor
    func loadCompanyInfo() async {
        self.viewState = .loading
        
        do {
            let companyInfo = try await companiesHouseService.loadCompanyDetails(companyNumber: getCompanyNumber)
            
            if companyInfo.companyStatus.lowercased() == "dissolved" {
                self.viewState = .error(MessageCenter.MessageType.companyDissolved.message)
                return
            }
            
            // Update properties from API response
            self.username = companyInfo.companyName
            self.companyNumber = companyInfo.companyNumber
            
            self.companiesHouseViewState = .success
            self.viewState = .idle
        } catch {
            self.viewState = .error(MessageCenter.MessageType.companyLoadingFailure.message)
        }
    }
    
    @MainActor
    func resetState() {
        imageSelection = nil
        avatarImage = nil
        displayName = ""
        viewState = .idle
        companiesHouseViewState = .idle
        imageViewState = .idle
        
        username = ""
        isDealer = false
        address = ""
        location = ""
        postcode = ""
        companyNumber = ""
        website = "https://"
        
        isProfileUpdated = false
        getCompanyNumber = ""
    }
    
    @MainActor
    func resetStateToIdle() {
        imageSelection = nil
        avatarImage = nil
        username = ""
        isDealer = false // added temporary
       
        imageViewState = .idle
        companiesHouseViewState = .idle
        viewState = .idle
    }
    
    @MainActor
    func enableDealerStatus() {
        isDealer = true
        companiesHouseViewState = .idle
        username = ""
    }
    
    @MainActor
    func disableDealerStatus() {
        isDealer = false
        companiesHouseViewState = .idle
        
        username = ""
        getCompanyNumber = ""
        companyNumber = ""
        address = ""
        location = ""
        postcode = ""
        website = "https://"
    }
    
    @MainActor
    func loadProfile() async {
        do {
            let userID = try await profileService.getCurrentUserID()
            let profile = try await profileService.loadProfile(for: userID)
            
            updateViewModelFromProfile(profile)
            await loadProhibitedWords()
            
            self.profile = profile
            self.username = ""
            
            // Only set to idle if we haven't updated profile
            if !isProfileUpdated {
                self.viewState = .idle
            }
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func updateProfileButtonTapped() async {
        guard checkForProhibitedWords() else {
            isProfileUpdated = true
            return
        }
        
        self.viewState = .loading
        
        do {
            let userID = try await profileService.getCurrentUserID()
            var imageURL = profile?.avatarURL
            
            // Upload new image if selected
            if let newImage = avatarImage {
                let folderPath = "\(userID)"
                let bucketName = "avatars"
                
                if let imageURLString = try await imageManager.uploadImage(newImage.data, from: bucketName, to: folderPath, targetWidth: 80, targetHeight: 80, compressionQuality: 0.4),
                   let uploadedImageURL = URL(string: imageURLString) {
                    imageURL = uploadedImageURL
                } else {
                    self.viewState = .error(MessageCenter.MessageType.profileImageUploadFailed.message)
                }
            }
            
            // Create updated profile
            let updatedProfile = Profile(
                username: username,
                avatarURL: imageURL,
                updatedAt: Date.now,
                userID: userID,
                isDealer: isDealer,
                address: isDealer ? address : nil,
                postcode: isDealer ? postcode : nil,
                location: isDealer ? location : nil,
                website: isDealer ? website : nil,
                companyNumber: isDealer ? companyNumber : nil
            )
            
            // Update profile
            try await profileService.updateProfile(updatedProfile)
            
            // Update local state
            self.profile = updatedProfile
            self.displayName = username
            isProfileUpdated = true
            
            viewState = .success(MessageCenter.MessageType.profileUpdateSuccess.message)
        } catch {
            viewState = .error(MessageCenter.MessageType.sensitiveApiNotEnabled.message)
        }
    }
    
    @MainActor
    func loadItem(item: PhotosPickerItem) async {
        self.imageViewState = .loading
        let result = await imageManager.loadItem(item: item, analyze: true)
        
        switch result {
        case .success(let pickedImage):
            avatarImage = pickedImage
            self.imageViewState = .success
            
        case .sensitiveContent:
            self.viewState = .error(MessageCenter.MessageType.sensitiveContent.message)
            
        case .analysisError:
            self.viewState = .sensitiveApiNotEnabled
            
        case .loadingError:
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    // MARK: - Private functions
    
    private func checkForProhibitedWords() -> Bool {
        let fieldsToCheck = [
            "username": username,
            "address": address,
            "location": location,
            "postcode": postcode,
            "companyNumber": companyNumber,
            "website": website
        ]
        let prohibitedWordsCheck = prohibitedWordsService.containsProhibitedWordsDictionary(in: fieldsToCheck)
        
        if prohibitedWordsCheck.values.contains(true) {
            _ = prohibitedWordsCheck.filter { $0.value }.keys.joined(separator: ", ")
            self.viewState = .error(MessageCenter.MessageType.inappropriateTextfieldInput.message)
            return false
        }
        return true
    }
    
    private func updateViewModelFromProfile(_ profile: Profile) {
        self.displayName = profile.username ?? ""
        self.username = profile.username ?? ""
        self.isDealer = profile.isDealer ?? false
        self.address = profile.address ?? ""
        self.location = profile.location ?? ""
        self.postcode = profile.postcode ?? ""
        self.companyNumber = profile.companyNumber ?? ""
        self.website = profile.website ?? "https://"
    }
    
    private func loadProhibitedWords() async {
        do {
            try await prohibitedWordsService.loadProhibitedWords()
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    // MARK: - Form validation
    
    var isInteractionBlocked: Bool {
        !validateUsername || (isDealer && !validateDealerFields)
    }
    
    var validateUsername: Bool {
        username.count >= 3 && username.count <= 20
    }
    
    var validateDealerFields: Bool {
        validateAddress && validateCity && validatePostCode && validateCompanyNumber
    }
    
    var validateAddress: Bool {
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var validateCity: Bool {
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var validatePostCode: Bool {
        let trimmedPostCode = postcode.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedPostCode.isEmpty && trimmedPostCode.count >= 5
    }
    
    var validateCompanyNumber: Bool {
        !companyNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

