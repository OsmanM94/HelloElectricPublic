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
    let deleteAction: (PickedImage) async -> Void
   
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text("Delete Photo"),
                    message: Text("Are you sure you want to delete this photo?"),
                    primaryButton: .destructive(Text("Delete")) {
                        Task {
                            if let imageToDelete = imageToDelete {
                                await deleteAction(imageToDelete)
                            }
                            isPresented = false
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}

extension View {
    func deleteAlert(isPresented: Binding<Bool>, imageToDelete: Binding<PickedImage?>, deleteAction: @escaping (PickedImage) async -> Void) -> some View {
        self.modifier(DeleteAlertModifier(isPresented: isPresented, imageToDelete: imageToDelete, deleteAction: deleteAction))
    }
}
