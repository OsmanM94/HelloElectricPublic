//
//  VideoPlayerView.swift
//  Clin
//
//  Created by asia on 24/09/2024.
//

import SwiftUI
import AVKit

/// Custom sized video without background, respecting safe areas
// VideoPlayerView(videoName: "splashvideo",
//                fileExtension: "mov",
//                frameSize: CGSize(width: 300, height: 200),
//                ignoreSafeArea: false,
//                showBackground: false)

/// Full screen video without background, ignoring safe areas
// VideoPlayerView(videoName: "splashvideo",
//                fileExtension: "mov",
//                showBackground: false)


struct VideoPlayerView: View {
    @State private var viewModel: VideoPlayerViewModel
    let frameSize: CGSize?
      let frameAlignment: Alignment
      let ignoreSafeArea: Bool
      let showBackground: Bool
      
      init(videoName: String,
           fileExtension: String,
           frameSize: CGSize? = nil,
           ignoreSafeArea: Bool = true,
           showBackground: Bool = true,
           frameAlignment: Alignment = .center) {
          _viewModel = State(wrappedValue: VideoPlayerViewModel(videoName: videoName, fileExtension: fileExtension))
          self.frameSize = frameSize
          self.frameAlignment = frameAlignment
          self.ignoreSafeArea = ignoreSafeArea
          self.showBackground = showBackground
      }
    
    var body: some View {
        ZStack {
            if showBackground {
                Rectangle()
                    .foregroundStyle(.black)
                    .ignoresSafeArea(edges: ignoreSafeArea ? .all : [])
            }
            
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .frameAdjustment(size: frameSize, alignment: frameAlignment)
            }
        }
        .onAppear {
            viewModel.play()
        }
        .onDisappear {
            viewModel.stop()
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    VideoPlayerView(videoName: "splashvideo", fileExtension: "mov")
}

