//
//  NewFeatureRequestView.swift
//  Clin
//
//  Created by asia on 27/09/2024.
//

import SwiftUI

struct NewFeatureRequestView: View {
    @Bindable var viewModel: FeatureRequestViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            switch viewModel.newRequestViewState {
            case .loaded:
                mainContent
                
            case .success:
                SuccessView(message: "Request sent!", doneAction: {
                    dismiss()
                })
                
            case .error(let message):
                ErrorView(message: message, refreshMessage: "Try again", retryAction: {
                    viewModel.resetRequestState()
                }, systemImage: "xmark.circle.fill")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.newRequestViewState)
        .navigationTitle("New Request")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { viewModel.resetFields() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    hideKeyboard()
                } label: {
                    Text("Done")
                }
            }
        }
    }
    
    private var mainContent: some View {
        Form {
            Section("Name (optional)") {
                TextField("Name", text: $viewModel.name)
                    .autocorrectionDisabled()
                    .characterLimit($viewModel.name, limit: 30)
            }
            
            Section(header: Text("Short title")) {
                TextField("Title", text: $viewModel.title)
                    .autocorrectionDisabled()
                    .characterLimit($viewModel.title, limit: 30)
            }
            
            Section(header: Text("Description"), footer: Text("\(viewModel.description.count)/500")) {
                TextEditor(text: $viewModel.description)
                    .frame(height: 200)
                    .autocorrectionDisabled()
                    .characterLimit($viewModel.description, limit: 500)
            }
            
            Button("Submit") {
                Task {
                    await viewModel.createFeatureRequest()
                    await viewModel.loadFeatureRequests()
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.title.isEmpty || viewModel.description.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        NewFeatureRequestView(viewModel: FeatureRequestViewModel())
    }
}
