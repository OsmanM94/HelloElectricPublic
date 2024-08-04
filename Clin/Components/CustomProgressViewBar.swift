//
//  CustomProgressViewBar.swift
//  Clin
//
//  Created by asia on 24/07/2024.
//

import SwiftUI

struct CustomProgressViewBar: View {
    var progress: Double
    let progressText: [String] = [
        "Uploading...",
        "Analyzing...",
        "Security checks...",
        "Validating data...",
        "Optimizing...",
        "Saving changes...",
        "Syncing with server..."
    ]
        
    private var currentIndex: Int {
        Int(progress * Double(progressText.count))
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Image(decorative: "ev4")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(width: 350, height: 350)
            
            ForEach(progressText.indices, id: \.self) { index in
                HStack(spacing: 0) {
                    Text(progressText[index])
                        .font(.headline)
                    
                    Spacer(minLength: 0)
                    
                    if index < currentIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if index == currentIndex {
                        ProgressView()
                            .scaleEffect(0.9)
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal)
            }
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

#Preview("Sample Data") {
    PreviewTest()
}

fileprivate struct PreviewTest: View {
    var progress: Double = 0.0
    let progressText: [String] = [
        "Uploading...",
        "Analyzing...",
        "Security checks...",
        "Validating data...",
        "Optimizing...",
        "Saving changes...",
        "Syncing with server..."
    ]
    private var currentIndex: Int {
        Int(simulatedProgress * Double(progressText.count))
    }
    
    @State private var simulatedProgress: Double = 0.0
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 5) {
            Image(decorative: "ev4")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(width: 350, height: 350)
            ForEach(progressText.indices, id: \.self) { index in
                HStack(spacing: 0) {
                    Text(progressText[index])
                        .font(.headline)
                    
                    Spacer(minLength: 0)
                    
                    if index < currentIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if index == currentIndex {
                        ProgressView()
                            .scaleEffect(0.9)
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal)
            }
            
            ProgressView(value: progress)
                .animation(.easeInOut, value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .padding()
        }
        .onAppear {
            startSimulatingProgress()
        }
        .onDisappear {
            stopSimulatingProgress()
        }
    }
    
    private func startSimulatingProgress() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            simulatedProgress += 1.0 / Double(progressText.count)
            if simulatedProgress >= 1.0 {
                stopSimulatingProgress()
            }
        }
    }
    
    private func stopSimulatingProgress() {
        timer?.invalidate()
        timer = nil
    }
}
