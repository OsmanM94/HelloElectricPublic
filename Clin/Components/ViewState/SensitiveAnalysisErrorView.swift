//
//  SensitiveAnalysisErrorView.swift
//  Clin
//
//  Created by asia on 12/08/2024.
//

import SwiftUI

struct SensitiveAnalysisErrorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPopover: Bool = false
    @State private var triggerFeedback: Bool = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let retryAction: () -> Void
    
    var body: some View {
        ZoomImages {
            VStack(spacing: 20) {
                sensitiveImagesGrid
                
                infoBox
                
                retryButton
                
                Spacer()
                
                whyRequiredButton
            }
            .padding()
            .sensitiveContentAnalysisCheck()
            .navigationTitle("Sensitive content")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: triggerApiNotEnabledFeedback)
            .sensoryFeedback(.warning, trigger: triggerFeedback)
            .onDisappear { triggerFeedback = false }
        }
    }
    
    private func triggerApiNotEnabledFeedback() {
        performAfterDelay(0.1) {
            triggerFeedback.toggle()
        }
    }
    
    private var sensitiveImagesGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(1...3, id: \.self) { index in
                if let image = UIImage(named: "sensitive\(index)")?.resize(300, 300) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.top)
    }
    
    private var infoBox: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.viewfinder.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            
            Text("Sensitive Content Warning Required")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("To maintain a safe environment, please enable Sensitive Content Warning in your device settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Settings > Privacy & Security > Sensitive Content Warning")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.lightGrayBackground, in: .rect(cornerRadius: 10))
    }
    
    private var retryButton: some View {
        Button(action: retryAction) {
            Text("Retry")
                .font(.headline)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color.tabColour.opacity(0.8) : Color.tabColour
    }

    
    private var whyRequiredButton: some View {
        Button(action: { showPopover = true }) {
            Text("Why is this required?")
                .font(.subheadline)
                .foregroundStyle(.blue)
                .fontDesign(.rounded)
                .bold()
        }
        .popover(isPresented: $showPopover) {
            whyRequiredPopover
        }
    }
    
    private var whyRequiredPopover: some View {
        VStack(spacing: 15) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.tabColour)
            
            Text("Why Enable Sensitive Content Warning?")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("This feature helps analyze images for inappropriate content before upload, ensuring a safe and respectful environment for all users in our EV marketplace.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding()
            
            Button("Got it") {
                showPopover = false
            }
            .buttonStyle(.bordered)
        }
        .fontDesign(.rounded)
        .presentationCompactAdaptation(.sheet)
    }
}


#Preview {
    SensitiveAnalysisErrorView(retryAction: {})
}

