//
//  MissingBrands.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI

struct SupportButton: View {
    let buttonText: String
    let phoneNumber: String = "07466861602"
    let textColor: Color
    let font: Font
    
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sorry, cannot initiate call"),
                message: Text("Your device is unable to make phone calls."),
                dismissButton: .default(Text("OK"))
            )
        }
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
    SupportButton(buttonText: "Missing models? Call support")
}
