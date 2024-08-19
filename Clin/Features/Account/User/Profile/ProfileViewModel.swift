//
//  ProfileViewModel.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//
import SwiftUI
import PhotosUI
import Factory


final class ProfileViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case error(String)
        case sensitiveApiNotEnabled
        case success(String)
    }
    
    @Published var username: String = ""
    @Published var imageSelection: PhotosPickerItem?
    @Published private(set) var avatarImage: SelectedImage?
    @Published private(set) var displayName: String = ""
    @Published private(set) var profile: Profile? = nil
    @Published private(set) var cooldownTime: Int = 0
   
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var cooldownTimer: Timer?
    
    @Injected(\.prohibitedWordsService) private var prohibitedWordsService
    @Injected(\.imageManager) private var imageManager
    @Injected(\.profileService) private var profileService
    
    init() {
        print("DEBUG: Did init ProfileViewModel")
    }
    
    var isInteractionBlocked: Bool {
        return cooldownTime > 0 || !validateUsername
    }
    
    @MainActor
    func resetState() {
        username = ""
        imageSelection = nil
        avatarImage = nil
        viewState = .idle
    }
    
    func loadProhibitedWords() async {
        do {
            try await prohibitedWordsService.loadProhibitedWords()
        } catch {
            print("Failed to load prohibited words: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func getInitialProfile() async {
        do {
            let userID = try await profileService.getCurrentUserID()
            let profile = try await profileService.getProfile(for: userID)
            self.displayName = profile.username ?? ""
            self.profile = profile
        } catch {
            debugPrint(error)
            viewState = .error(ProfileViewStateMessages.generalError.message)
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
                viewState = .error(ProfileViewStateMessages.generalError.message)
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
            
            self.profile?.avatarURL = imageURL
            self.username = ""
            
            startCooldownTimer()
            viewState = .success(ProfileViewStateMessages.success.message)
        } catch {
            debugPrint(error)
            viewState = .error(ProfileViewStateMessages.sensitiveApiNotEnabled.message)
        }
    }
    
    @MainActor
    private func canUpdateProfile() async -> Bool {
        guard cooldownTime == 0 else {
            viewState = .error(ProfileViewStateMessages.generalError.message)
            return false
        }
        
        guard !prohibitedWordsService.containsProhibitedWord(username) else {
            viewState = .error(ProfileViewStateMessages.inappropriateUsername.message)
            return false
        }
        
        viewState = .loading
        
        // Check if only the username needs to be updated
        if await !shouldProceedWithUpdate() {
            return false
        }
        
        guard avatarImage?.data != nil else {
            viewState = .error(ProfileViewStateMessages.generalError.message)
            return false
        }
        return true
    }
    
    @MainActor
    private func shouldProceedWithUpdate() async -> Bool {
        if avatarImage == nil || avatarImage?.data == nil {
            await updateUsernameOnly()
            print("Username updated.")
            return false
        }
        return true
    }
    
    @MainActor
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
            viewState = .success(ProfileViewStateMessages.success.message)
            startCooldownTimer()
        } catch {
            debugPrint(error)
            viewState = .error(ProfileViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    func loadItem(item: PhotosPickerItem) async {
        let result = await imageManager.loadItem(item: item, analyze: true)
        
        switch result {
        case .success(let pickedImage):
            avatarImage = pickedImage
        case .sensitiveContent:
            viewState = .error(ProfileViewStateMessages.sensitiveContent.message)
        case .analysisError:
            viewState = .sensitiveApiNotEnabled
        case .loadingError:
            viewState = .error(ProfileViewStateMessages.generalError.message)
        }
    }
    
    private func startCooldownTimer() {
        cooldownTime = 60 // 1 minute cooldown period, adjust as needed
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.cooldownTime > 0 {
                self.cooldownTime -= 1
            } else {
                timer.invalidate()
                self.cooldownTimer = nil
            }
        }
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





