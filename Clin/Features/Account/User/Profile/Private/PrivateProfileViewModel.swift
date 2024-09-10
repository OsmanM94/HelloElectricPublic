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
final class PrivateProfileViewModel {
    // MARK: - Enums
    enum ViewState: Equatable {
        case idle
        case loading
        case error(String)
        case sensitiveApiNotEnabled
        case success(String)
    }
    
    // MARK: - Observable properties
    var username: String = ""
    var imageSelection: PhotosPickerItem?
    private(set) var avatarImage: SelectedImage?
    private(set) var displayName: String = ""
    private(set) var profile: Profile? = nil
    private(set) var viewState: ViewState = .idle
    
    
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
        imageSelection = nil
        avatarImage = nil
        viewState = .idle
    }
        
    @MainActor
    func loadPrivateProfile() async {
        do {
            let userID = try await profileService.getCurrentUserID()
            let profile = try await profileService.loadProfile(for: userID)
            self.displayName = profile.username ?? ""
            self.profile = profile
        } catch {
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
   
    @MainActor
    func updateProfileButtonTapped() async {
        guard await canUpdateProfile() else { return }
        
        do {
            let userID = try await profileService.getCurrentUserID()
            let folderPath = "\(userID)"
            let bucketName = "avatars"
            
            let imageURLString = try await imageManager.uploadImage(avatarImage!.data, from: bucketName, to: folderPath,targetWidth: 80, targetHeight: 80, compressionQuality: 0.4)
            
            guard let imageURL = URL(string: imageURLString ?? "") else {
                viewState = .error(AppError.ErrorType.generalError.message)
                return
            }
            
            let updatedProfile = Profile(
                username: username,
                avatarURL: imageURL,
                updatedAt: Date.now,
                userID: userID
            )
            
            try await profileService.updateProfile(updatedProfile)
            self.profile?.avatarURL = imageURL
            self.username = ""
            
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
    
    // MARK: - Helpers and misc
    
    private func canUpdateProfile() async -> Bool {
        guard !prohibitedWordsService.containsProhibitedWord(username) else {
            viewState = .error(AppError.ErrorType.inappropriateUsername.message)
            return false
        }
        
        viewState = .loading
        
        // Check if only the username needs to be updated
        if await !shouldProceedWithUpdate() {
            return false
        }
        
        guard avatarImage?.data != nil else {
            viewState = .error(AppError.ErrorType.generalError.message)
            return false
        }
        return true
    }
    
    private func shouldProceedWithUpdate() async -> Bool {
        if avatarImage == nil || avatarImage?.data == nil {
            await updateUsernameOnly()
            print("Username updated.")
            return false
        }
        return true
    }
    
    private func updateUsernameOnly() async {
        do {
            let currentUser = try await profileService.getCurrentUserID()
            
            let updatedProfile = Profile(
                username: username,
                avatarURL: profile?.avatarURL, // Keep the existing avatar URL
                updatedAt: Date.now,
                userID: currentUser
            )
            
            try await profileService.updateProfile(updatedProfile)
            
            self.profile?.username = username
            self.username = ""
            viewState = .success(AppError.ErrorType.profileUpdateSuccess.message)
        } catch {
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    func loadProhibitedWords() async {
        do {
            try await prohibitedWordsService.loadProhibitedWords()
        } catch {
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    var isInteractionBlocked: Bool {
        !validateUsername
    }
    
    var validateUsername: Bool {
        if username.count < 3 {
            return false
        } else if username.count > 20 {
            return false
        }
        return true
    }
}





