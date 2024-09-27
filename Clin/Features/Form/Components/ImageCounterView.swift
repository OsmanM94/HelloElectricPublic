//
//  ImageCounterView.swift
//  Clin
//
//  Created by asia on 22/08/2024.
//

import SwiftUI

struct ImageCounterView: View {
    let count: Int
    @Binding var isLoading: Bool
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                Image(systemName: count <= 0 ? "photo.badge.plus" : "photo")
                    .foregroundStyle(.gray)
                    .font(.system(size: 25))
                    .symbolRenderingMode(.multicolor)
            }
            
            if count > 0 {
                Text("\(min(count, 99))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(isLoading ? .orange : .tabColour)
                    .clipShape(Circle())
                    .offset(x: 15, y: -10)
            }
        }
        .frame(width: 44, height: 44)
    }
}

struct ImageCounterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack(spacing: 20) {
                ImageCounterView(count: 0, isLoading: .constant(false))
                ImageCounterView(count: 5, isLoading: .constant(false))
                ImageCounterView(count: 99, isLoading: .constant(false))
                ImageCounterView(count: 3, isLoading: .constant(true))
            }
            .previewLayout(.sizeThatFits)
            .padding()
            
            // Preview in a toolbar
            NavigationStack {
                Text("Content")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            ImageCounterView(count: 5, isLoading: .constant(false))
                        }
                    }
            }
        }
    }
}

