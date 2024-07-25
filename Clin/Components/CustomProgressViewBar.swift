//
//  CustomProgressViewBar.swift
//  Clin
//
//  Created by asia on 24/07/2024.
//

import SwiftUI

struct CustomProgressViewBar: View {
    var progress: Double
    
    var body: some View {
        VStack {
            Text("Uploading...")
                .font(.headline)
            ProgressView(value: progress)
                .animation(.easeInOut, value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .padding()
        }
    }
}

#Preview {
    CustomProgressViewBar(progress: 0.5)
}
