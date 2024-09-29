//
//  IntroView.swift
//  Clin
//
//  Created by asia on 24/09/2024.
//

import SwiftUI

struct IntroView: View {
    @State private var showSplashView: Bool = true
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Group {
                if colorScheme == .dark && showSplashView {
                    VideoPlayerView(
                        videoName: "introvideo",
                        fileExtension: "mov"
                    )
                    .scaleEffect(1.9)
                } else {
                    MarketView()
                }
            }
        }
        .onAppear {
            performAfterDelay(2.5) {
                withAnimation(.easeInOut) {
                    showSplashView = false
                }
            }
        }
    }
}

#Preview {
    IntroView()
        .environment(AuthViewModel())
        .environment(FavouriteViewModel())
        .environment(AccountViewModel())
}
