//
//  SensitiveAnalysisErrorView.swift
//  Clin
//
//  Created by asia on 12/08/2024.
//

import SwiftUI

struct SensitiveAnalysisErrorView: View {
    @State private var showPopover: Bool = false
    let retryAction: () -> Void
    
    var body: some View {
        ZoomImages {
            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    if let sensitive1 = UIImage(named: "sensitive1")?.resize(200, 200) {
                        Image(uiImage: sensitive1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    if let sensitive2 = UIImage(named: "sensitive2")?.resize(200, 200) {
                        Image(uiImage: sensitive2)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    if let sensitive3 = UIImage(named: "sensitive3")?.resize(200, 200) {
                        Image(uiImage: sensitive3)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top)
                
                Spacer(minLength: 0)
                
                GroupBox {
                    Text("Please enable Sensitive Content Warning")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    Text("Go to Settings > Privacy & Security > Sensitive Content Warning.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: { retryAction() }) {
                        Text("Retry")
                            .font(.title3)
                    }
                    .padding(.top, 5)
                }
                
                Spacer(minLength: 0)
                
                Button(action: {
                    showPopover = true
                }) {
                    Text("Why is this required?")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .popover(isPresented: $showPopover) {
                    VStack(spacing: 10) {
                        Text("Why Enable Sensitive Content Warning?")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Text("Sensitive Content Warning is required to analyze your images for inappropriate content, such as nudity, before they are uploaded. This helps maintain a safe and respectful environment.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding()
                        
                        Button("Got it") {
                            showPopover = false
                        }
                        .padding(.top)
                        .buttonStyle(.borderedProminent)
                    }
                    .presentationCompactAdaptation(.sheet)
                    .padding()
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            .sensitiveContentAnalysisCheck()
        }
    }
}

#Preview {
    SensitiveAnalysisErrorView(retryAction: {})
}
