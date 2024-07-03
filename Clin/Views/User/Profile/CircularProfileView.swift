//
//  CircularProfileView.swift
//  Clin
//
//  Created by asia on 30/06/2024.
//

import SwiftUI

struct CircularProfileView: View {
//    let username: String
    let size: ProfileImageSize
    var profile: Profile?
    
    var body: some View {
        HStack {
            Group {
                ZStack {
                    if let imageUrl = profile?.avatarURL {
                        ImageLoader(url: imageUrl, contentMode: .fill)
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
            
//            Text(username)
//                .font(.title3)
//                .fontWeight(.semibold)
//                .padding(.leading)
//            
//            Spacer()
        }
    }
}

//#Preview {
//    CircularProfileView()
//}
