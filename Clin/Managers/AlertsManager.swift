//
//  DeleteAlertModifier.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import SwiftUI

struct AlertsManager<Item: Identifiable>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var itemToDelete: Item?
    let action: (Item) async -> Void
    let message: String
    let title: String
    let cancelButtonText: String
    let deleteButtonText: String

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented, presenting: itemToDelete) { item in
                Button(cancelButtonText, role: .cancel) {
                    isPresented = false
                }
                Button(deleteButtonText, role: .destructive) {
                    Task {
                        await action(item)
                        isPresented = false
                    }
                }
            } message: { _ in
                Text(message)
            }
    }
}

extension View {
    func showDeleteAlert<Item: Identifiable>(
        isPresented: Binding<Bool>,
        itemToDelete: Binding<Item?>,
        message: String,
        title: String ,
        cancelButtonText: String = "Cancel",
        deleteButtonText: String = "Delete",
        deleteAction: @escaping (Item) async -> Void
    ) -> some View {
        self.modifier(AlertsManager(
            isPresented: isPresented,
            itemToDelete: itemToDelete,
            action: deleteAction,
            message: message,
            title: title,
            cancelButtonText: cancelButtonText,
            deleteButtonText: deleteButtonText
        ))
    }
    
    func showStandardAlert(
        isPresented: Binding<Bool>,
        message: String,
        title: String,
        cancelButtonText: String = "Cancel",
        deleteButtonText: String = "Delete",
        deleteAction: @escaping () async -> Void
    ) -> some View {
        self.alert(title, isPresented: isPresented) {
            Button(cancelButtonText, role: .cancel) { }
            Button(deleteButtonText, role: .destructive) {
                Task {
                     await deleteAction()
                }
            }
        } message: {
            Text(message)
        }
    }
    
    func simpleAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        dismissButtonText: String = "OK"
    ) -> some View {
        self.alert(title, isPresented: isPresented) {
            Button(dismissButtonText, role: .cancel) { }
        } message: {
            Text(message)
        }
    }
}
