//
//  ReportButton.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI

struct ReportButton: View {
    let itemId: Int
    let itemType: String
    let iconSize: CGFloat
    let supportEmail = AppConstants.Contact.supportEmail
    
    @State private var showReportAlert: Bool = false
    
    var body: some View {
        Button(action: { showReportAlert = true }) {
            Image(systemName: "flag")
                .foregroundStyle(.red)
                .font(.system(size: iconSize))
        }
        .alert("Report \(itemType)", isPresented: $showReportAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Report", role: .destructive, action: reportItem)
        } message: {
            Text("Are you sure you want to report this \(itemType.lowercased())?")
        }
    }
    
    private func reportItem() {
        let subject = "Reporting \(itemType): \(itemId)"
        let body = "I would like to report the \(itemType.lowercased()) with ID: \(itemId)"
        
        let urlString = "mailto:\(supportEmail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open e-mail...")
        }
    }
}

#Preview {
    ReportButton(itemId: 1994, itemType: "Listing", iconSize: 22)
}
