//
//  SensitiveContentAnalysis.swift
//  Clin
//
//  Created by asia on 04/07/2024.
//

import Foundation
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
    
    var analysisState: AnalysisState = .notStarted
    
    private init() {}
    
    @MainActor
    func analyze(image: Data) async {
        analysisState = .analyzing
        let analyzer = SCSensitivityAnalyzer()
        let policy = analyzer.analysisPolicy
    
        if policy == .disabled {
            print("Policy is disabled")
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
            print("Unable to get a response", error)
        }
    }
}

