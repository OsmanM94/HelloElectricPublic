//
//  DeleteAlertModifier.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import SwiftUI

struct DeleteAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var imageToDelete: PickedImage?
    let deleteAction: (PickedImage) -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text("Delete Photo"),
                    message: Text("Are you sure you want to delete this photo?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let imageToDelete = imageToDelete {
                            deleteAction(imageToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}

extension View {
    func deleteAlert(isPresented: Binding<Bool>, imageToDelete: Binding<PickedImage?>, deleteAction: @escaping (PickedImage) -> Void) -> some View {
        self.modifier(DeleteAlertModifier(isPresented: isPresented, imageToDelete: imageToDelete, deleteAction: deleteAction))
    }
}
