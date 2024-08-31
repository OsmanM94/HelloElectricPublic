//
//  CircularProfileView.swift
//  Clin
//
//  Created by asia on 30/06/2024.
//

import SwiftUI

enum ProfileImageSize {
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case xxLarge
    
    var dimension: CGFloat {
        switch self {
        case .xxSmall:
            return 28
        case .xSmall:
            return 32
        case .small:
            return 40
        case .medium:
            return 56
        case .large:
            return 64
        case .xLarge:
            return 80
        case .xxLarge:
            return 120
        }
    }
}

struct CircularProfileView: View {
    let size: ProfileImageSize
    var profile: Profile?
   
    var body: some View {
        HStack {
            Group {
                ZStack {
                    if let imageUrl = profile?.avatarURL {
                        ImageLoader(url: imageUrl, contentMode: .fill, targetSize: CGSize(width: 80, height: 80))
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .foregroundStyle(.gray)
                            .frame(width: size.dimension, height: size.dimension)
                    }
                }
            }
            .scaledToFill()
            .clipShape(Circle())
            .frame(width: size.dimension, height: size.dimension)
        }
        .padding()
    }
}

#Preview {
    CircularProfileView(size: ProfileImageSize.xLarge)
}
