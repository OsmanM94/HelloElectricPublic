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
    var isLoading: Bool = false
    var imageSelection: PhotosPickerItem?
    var avatarImage: AvatarImage?
    var displayName: String = ""
    var profile: Profile? = nil
    
    private let supabase = SupabaseService.shared.client
    private let profileService = ProfileService()

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
        }
    }
    
    @MainActor
    func updateProfileButtonTapped() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let currentAvatarURL = profile?.avatarURL {
                try await deleteImage(path: currentAvatarURL.absoluteString)
            }
                        
            let imageURLString = try await uploadImage()
            guard let imageURL = URL(string: imageURLString ?? "") else { return }
            
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
            
        } catch {
            debugPrint(error)
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
    
    private func downloadImage(path: String) async throws {
        let data = try await supabase.storage.from("avatars").download(path: path)
        avatarImage = AvatarImage(data: data)
        print("Image downloaded from Supabase Storage")
    }
    
    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { return nil }
        
        guard let compressedData = compressImage(data: data) else {
            print("Failed to compress image")
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
}
