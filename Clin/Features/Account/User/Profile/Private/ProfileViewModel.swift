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
    
    // MARK: - Observable properties
    var imageSelection: PhotosPickerItem?
    private(set) var avatarImage: SelectedImage?
    private(set) var displayName: String = ""
    private(set) var profile: Profile? = nil
    private(set) var viewState: ViewState = .loading
    
    var username: String = ""
    var isDealer: Bool = false
    var address: String = ""
    var location: String = ""
    var postcode: String = ""
    var companyNumber: String = ""
    var website: String = "https://"
    
    var isProfileUpdated: Bool = false

    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.prohibitedWordsService) private var prohibitedWordsService
    @ObservationIgnored @Injected(\.imageManager) private var imageManager
    @ObservationIgnored @Injected(\.profileService) private var profileService
    
    init() {
        print("DEBUG: Did init profile vm")
    }
    
    // MARK: - Main actor functions
    @MainActor
    func resetState() {
        username = ""
        isDealer = false
        isProfileUpdated = false
        address = ""
        location = ""
        postcode = ""
        website = ""
        imageSelection = nil
        avatarImage = nil
        viewState = .loading
    }
    
    @MainActor
    func resetStateToIdle() {
        imageSelection = nil
        avatarImage = nil
        viewState = .idle
    }
        
    @MainActor
    func loadProfile() async {
        do {
            let userID = try await profileService.getCurrentUserID()
            let profile = try await profileService.loadProfile(for: userID)
            
            updateViewModelFromProfile(profile)
            await loadProhibitedWords()
            
            self.profile = profile
            
            // Only set to idle if we haven't updated profile
            if !isProfileUpdated {
                viewState = .idle
            }
        } catch {
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    @MainActor
    func updateProfileButtonTapped() async {
        guard !prohibitedWordsService.containsProhibitedWord(username) else {
            viewState = .error(AppError.ErrorType.inappropriateUsername.message)
            return
        }
        
        viewState = .loading
        
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
                    viewState = .error(AppError.ErrorType.profileImageUploadFailed.message)
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
            viewState = .success(AppError.ErrorType.profileUpdateSuccess.message)
        } catch {
            viewState = .error(AppError.ErrorType.sensitiveApiNotEnabled.message)
        }
    }
    
    @MainActor
    func loadItem(item: PhotosPickerItem) async {
        let result = await imageManager.loadItem(item: item, analyze: true)
        
        switch result {
        case .success(let pickedImage):
            avatarImage = pickedImage
        case .sensitiveContent:
            viewState = .error(AppError.ErrorType.sensitiveContent.message)
        case .analysisError:
            viewState = .sensitiveApiNotEnabled
        case .loadingError:
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    // MARK: - Private methods
    
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
            print("Error loading prohibited words")
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





