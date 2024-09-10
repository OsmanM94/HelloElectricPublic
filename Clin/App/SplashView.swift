//
//  SplashView.swift
//  Clin
//
//  Created by asia on 08/09/2024.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(decorative: "electric-car")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
            
            Text("HelloElectric")
                .font(.system(size: 48, weight: .bold, design: .rounded))
        
            Text("The destination to go for EVs.")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 10)
        }
        .padding(.bottom, 50)
    }
}

#Preview {
    SplashView()
}
