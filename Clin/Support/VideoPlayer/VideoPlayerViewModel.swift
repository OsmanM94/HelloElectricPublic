//
//  VideoPlayerViewModel.swift
//  Clin
//
//  Created by asia on 24/09/2024.
//

import SwiftUI
import AVKit


@Observable
final class VideoPlayerViewModel {
    var player: AVPlayer?
    private let videoName: String
    private let fileExtension: String
    
    init(videoName: String, fileExtension: String) {
        self.videoName = videoName
        self.fileExtension = fileExtension
        setupPlayer()
    }
    
    private func setupPlayer() {
        if let fileURL = Bundle.main.url(forResource: videoName, withExtension: fileExtension) {
            player = AVPlayer(url: fileURL)
        }
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }
}
