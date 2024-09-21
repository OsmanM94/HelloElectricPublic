//
//  MissingBrands.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI

struct MissingDataSupport: View {
    let buttonText: String
    let textColor: Color
    let font: Font
    
    let phoneNumber = AppConstants.Contact.phoneNumber
    
    @State private var showAlert: Bool = false
    
    init(
        buttonText: String = "Missing models? Call support",
        textColor: Color = .blue,
        font: Font = .footnote
    ) {
        self.buttonText = buttonText
        self.textColor = textColor
        self.font = font
    }
    
    var body: some View {
        Button(action: promptPhoneCall) {
            Text(buttonText)
                .font(font)
                .foregroundStyle(textColor)
        }
        .simpleAlert(
            isPresented: $showAlert,
            title: "Sorry, cannot initiate call",
            message: "Your device is unable to make phone calls."
        )
        .onDisappear { showAlert = false }
    }
    
    private func promptPhoneCall() {
        if let url = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlert = true
        }
    }
}

#Preview {
    MissingDataSupport(buttonText: "Missing models? Call support")
}
