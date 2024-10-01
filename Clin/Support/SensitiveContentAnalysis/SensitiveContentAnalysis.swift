//
//  SensitiveContentAnalysis.swift
//  Clin
//
//  Created by asia on 04/07/2024.
//
import SwiftUI
import SensitiveContentAnalysis

enum AnalysisState: Equatable {
    case notStarted
    case analyzing
    case isSensitive
    case notSensitive
    case error(message: String)
}

@Observable
final class SensitiveContentAnalysis {
    static let shared = SensitiveContentAnalysis()
    
    private init() {}
    
    var analysisState: AnalysisState = .notStarted
    
    @MainActor
    func analyze(image: Data) async {
        analysisState = .analyzing
        let analyzer = SCSensitivityAnalyzer()
        let policy = analyzer.analysisPolicy
        
        if policy == .disabled {
            analysisState = .error(message: "Policy is disabled")
            return
        }
        
        do {
            guard let image = UIImage(data: image)?.cgImage else {
                analysisState = .error(message: "Unable to create image from data")
                return
            }
            
            let response = try await analyzer.analyzeImage(image)
            
            analysisState = response.isSensitive ? .isSensitive : .notSensitive
        } catch {
            analysisState = .error(message: error.localizedDescription)
        }
    }
}

struct SensitiveContentAnalysisModifier: ViewModifier {
    @Bindable var analysis = SensitiveContentAnalysis.shared
    
    func body(content: Content) -> some View {
        content
            .showStandardAlert(
                isPresented: .constant(analysis.analysisState == .error(message: "Policy is disabled")),
                message: "Settings > Privacy & Security > Sensitive Content Warning.",
                title: "Enable Sensitive Content Analysis to upload photos.",
                cancelButtonText: "Cancel",
                deleteButtonText: "Go to Settings",
                deleteAction: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )
    }
}



