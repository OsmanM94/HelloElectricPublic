//
//  ProfileViewModel.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//

import Foundation
import SwiftUI
import PhotosUI
import Storage

@Observable
final class ProfileViewModel {
    enum ProfileViewState {
        case idle
        case loading
        case error(String)
        case success(String)
    }
    
    var username: String = ""
    var imageSelection: PhotosPickerItem?
    private(set) var avatarImage: AvatarImage?
    private(set) var displayName: String = ""
    private(set) var profile: Profile? = nil
    private(set) var cooldownTime: Int = 0
    
    private let supabase = SupabaseService.shared.client
    private let imageService = ImageService.shared // Use ImageService
    private let contentAnalyzer = SensitiveContentAnalysis.shared
    
    private(set) var viewState: ProfileViewState = .idle
    private(set) var cooldownTimer: Timer?
    private(set) var prohibitedWords: Set<String> = []
        
    var isInteractionBlocked: Bool {
        return cooldownTime > 0 || !validateUsername
    }
    
    func resetState() {
        username = ""
        imageSelection = nil
        avatarImage = nil
        viewState = .idle
    }
    
    func loadProhibitedWords() async {
        do {
            let words: [String] = try await loadAsync("prohibited_words.json")
            self.prohibitedWords = Set(words)
            
        } catch let error as JSONLoadingError {
            print("Failed to load prohibited words: \(error.localizedDescription)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    @MainActor
    func getInitialProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user
            
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("user_id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            self.displayName = profile.username ?? ""
            self.profile = profile
           
        } catch {
            debugPrint(error)
            viewState = .error(ProfileError.generalError.message)
        }
    }
    
    @MainActor
    func updateProfileButtonTapped() async {
        
        guard await canUpdateProfile() else { return }
        
        do {
            if let currentAvatarURL = profile?.avatarURL {
                try await imageService.deleteImage(path: currentAvatarURL.absoluteString)
            }
                        
            let imageURLString = try await imageService.uploadImage(avatarImage!.data)
            guard let imageURL = URL(string: imageURLString ?? "") else {
                viewState = .error(ProfileError.generalError.message)
                return
            }
            
            let currentUser = try await supabase.auth.session.user
            
            let updatedProfile = Profile(
                username: username,
                avatarURL: imageURL,
                updatedAt: Date.now,
                userID: currentUser.id
            )
            
            try await supabase
                .from("profiles")
                .update(updatedProfile)
                .eq("user_id", value: currentUser.id)
                .execute()
                       
            self.profile?.avatarURL = imageURL
            self.username = ""
                        
            startCooldownTimer()
            viewState = .success("Profile updated successfully.")
            
        } catch {
            debugPrint(error)
            viewState = .error(ProfileError.generalError.message)
        }
    }
    
    @MainActor
    private func canUpdateProfile() async -> Bool {
        guard cooldownTime == 0 else {
            viewState = .error(ProfileError.generalError.message)
            return false
        }
        
        guard !containsProhibitedWords(username) else {
            viewState = .error(ProfileError.inappropriateUsername.message)
            return false
        }
        
        viewState = .loading
        
        // Check if only the username needs to be updated
        if await !shouldProceedWithUpdate() {
            return false
        }
        
        guard avatarImage?.data != nil else {
            viewState = .error(ProfileError.generalError.message)
            return false
        }
        
        return await analyzeImage()
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
            let currentUser = try await supabase.auth.session.user
            
            let updatedProfile = Profile(
                username: username,
                avatarURL: profile?.avatarURL, // Keep the existing avatar URL
                updatedAt: Date.now,
                userID: currentUser.id
            )
            
            try await supabase
                .from("profiles")
                .update(updatedProfile)
                .eq("user_id", value: currentUser.id)
                .execute()
            
            self.profile?.username = username
            self.username = ""
            viewState = .success("Username updated.")
            startCooldownTimer()
            
        } catch {
            debugPrint(error)
            viewState = .error(ProfileError.generalError.message)
        }
    }
    
    @MainActor
    private func analyzeImage() async -> Bool {
        guard let data = avatarImage?.data else { return false }
        
        let analysisResult = await imageService.analyzeImage(data)
       
        switch analysisResult {
        case .isSensitive:
            viewState = .error(ProfileError.sensitiveContent.message)
            return false
        case .error(let message):
            viewState = .error(message)
            return false
        case .notSensitive:
            return true
        case .analyzing, .notStarted:
            return false
        }
    }
        
    func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
                print("Image loaded from PhotosPicker")
            } catch {
                debugPrint(error)
            }
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
    
    private func containsProhibitedWords(_ text: String) -> Bool {
        let words = text.lowercased().split(separator: " ")
        return words.contains { prohibitedWords.contains(String($0)) }
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
