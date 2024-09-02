//
//  DeleteAlertModifier.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import SwiftUI

struct DeleteAlertModifier<Item: Identifiable>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var itemToDelete: Item?
    let deleteAction: (Item) async -> Void

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text("Delete Confirmation"),
                    message: Text("Are you sure you want to delete this item?"),
                    primaryButton: .destructive(Text("Delete")) {
                        Task {
                            if let itemToDelete = itemToDelete {
                                await deleteAction(itemToDelete)
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
    func deleteAlert<Item: Identifiable>(
        isPresented: Binding<Bool>,
        itemToDelete: Binding<Item?>,
        deleteAction: @escaping (Item) async -> Void
    ) -> some View {
        self.modifier(DeleteAlertModifier(isPresented: isPresented, itemToDelete: itemToDelete, deleteAction: deleteAction))
    }
}
