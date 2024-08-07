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
                Image(systemName: "checkmark.circle.fill")
                    
                    .foregroundStyle(.green)
            }
        } description: {
            Text("")
        } actions: {
            Button {
                doneAction()
            } label: {
                Text("Done")
                    .font(.title2)
            }

        }
    }
}

#Preview {
    SuccessView(message: "Profile updated succesfully.", doneAction: {})
}
