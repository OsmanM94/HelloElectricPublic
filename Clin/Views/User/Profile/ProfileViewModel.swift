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
    var username: String = ""
    var imageSelection: PhotosPickerItem?
    private(set) var avatarImage: AvatarImage?
    private(set) var displayName: String = ""
    private(set) var profile: Profile? = nil
    private(set) var cooldownTime: Int = 0
    private(set) var lastUploadedImageURL: String?
    
    private let supabase = SupabaseService.shared.client
    private let profileService = ProfileService()
    private let contentAnalyzer = SensitiveContentAnalysis.shared
    
    private(set) var profileViewState: ProfileViewState = .idle
    private(set) var cooldownTimer: Timer?
    private(set) var prohibitedWords: Set<String> = []
    
    init() {
        Task {
            await loadProhibitedWords()
        }
    }
    
    var isInteractionBlocked: Bool {
        return cooldownTime > 0 || !validateUsername
    }
    
    func resetState() {
        username = ""
        imageSelection = nil
        avatarImage = nil
        profileViewState = .idle
    }
    
    private func loadProhibitedWords() async {
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
            profileViewState = .error(ProfileError.generalError.message)
        }
    }
    
    @MainActor
    func updateProfileButtonTapped() async {
        
        guard await canUpdateProfile() else { return }
        
        do {
            if let currentAvatarURL = profile?.avatarURL {
                try await deleteImage(path: currentAvatarURL.absoluteString)
            }
                        
            let imageURLString = try await uploadImage()
            guard let imageURL = URL(string: imageURLString ?? "") else {
                profileViewState = .error(ProfileError.generalError.message)
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
            
            self.lastUploadedImageURL = imageURL.absoluteString
            
            startCooldownTimer()
            profileViewState = .success("Profile updated.")
            
        } catch {
            debugPrint(error)
            profileViewState = .error(ProfileError.generalError.message)
        }
    }
    
    @MainActor
    private func canUpdateProfile() async -> Bool {
        guard cooldownTime == 0 else {
            profileViewState = .error(ProfileError.cooldownActive.message)
            return false
        }
        
        guard !containsProhibitedWords(username) else {
            profileViewState = .error(ProfileError.inappropriateUsername.message)
            return false
        }
        
        profileViewState = .loading
        
        if let profileImageURL = profile?.avatarURL?.absoluteString, profileImageURL == lastUploadedImageURL {
            profileViewState = .error(ProfileError.duplicateImage.message)
            return false
        }
        
        guard avatarImage?.data != nil else {
            profileViewState = .error(ProfileError.generalError.message)
            return false
        }
        
        return await analyzeImage()
    }
    
    @MainActor
    private func analyzeImage() async -> Bool {
        guard let data = avatarImage?.data else { return false }
        
        await contentAnalyzer.analyze(image: data)
        
        switch contentAnalyzer.analysisState {
        case .isSensitive:
            profileViewState = .error(ProfileError.sensitiveContent.message)
            return false
        case .error(let message):
            profileViewState = .error(message)
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
    
    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { return nil }
        
        guard let compressedData = compressImage(data: data) else {
            print("Failed to compress image.")
            return nil
        }
        
        let filePath = "\(UUID().uuidString).jpeg"

        try await supabase.storage
            .from("avatars")
            .upload(
                path: filePath,
                file: compressedData,
                options: FileOptions(contentType: "image/jpeg")
            )

        print("Image uploaded to Supabase Storage at path: \(filePath)")

        let url = try supabase.storage.from("avatars").getPublicURL(path: filePath, download: true)
        return url.absoluteString
    
    }
    
    private func compressImage(data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: 0.1)
    }
    
    private func deleteImage(path: String) async throws {
        do {
            let fileName = URL(string: path)?.lastPathComponent ?? ""
            _ = try await supabase.storage.from("avatars").remove(paths: [fileName])
            print("Image deleted from Supabase Storage at path: \(path)")
        } catch {
            print("Error deleting image from database: \(error)")
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
