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
    let message: String

    func body(content: Content) -> some View {
        content
            .alert("Delete Confirmation", isPresented: $isPresented, presenting: itemToDelete) { item in
                Button("Cancel", role: .cancel) {
                    isPresented = false
                }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteAction(item)
                        isPresented = false
                    }
                }
            } message: { _ in
                Text(message)
            }
    }
}

extension View {
    func deleteAlert<Item: Identifiable>(
        isPresented: Binding<Bool>,
        itemToDelete: Binding<Item?>,
        message: String,
        deleteAction: @escaping (Item) async -> Void
    ) -> some View {
        self.modifier(DeleteAlertModifier(
            isPresented: isPresented,
            itemToDelete: itemToDelete,
            deleteAction: deleteAction,
            message: message
        ))
    }
}
