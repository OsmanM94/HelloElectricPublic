//
//  SuccessView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct SuccessView: View {
    var message: String
    var doneAction: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label {
                Text(message)
                    .foregroundStyle(.green)
            } icon: {
                Image(systemName: "checkmark.circle")
                    
                    .foregroundStyle(.green)
            }
        } description: {
            Text("")
        } actions: {
            Button("Done") {
                doneAction()
            }
        }
    }
}

#Preview {
    SuccessView(message: "Profile updated succesfully.", doneAction: {})
}
