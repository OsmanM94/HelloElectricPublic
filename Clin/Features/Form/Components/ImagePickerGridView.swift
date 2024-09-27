//
//  FormGridView.swift
//  Clin
//
//  Created by asia on 16/08/2024.
//

import SwiftUI

enum ImageViewState: Equatable {
    case idle
    case sensitiveContent(String)
    case sensitiveApiNotEnabled
    case error(String)
}

struct ImagePickerGridView<ViewModel: ImagePickerProtocol>: View {
    @State var viewModel: ViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            switch viewModel.imageViewState {
            case .idle:
                gridView
                
            case .sensitiveContent(let message):
                ErrorView(message: message,
                          refreshMessage: "Try again",
                          retryAction: {
                    viewModel.resetImageStateToIdle()
                }, systemImage: "xmark.circle.fill")
                
            case .sensitiveApiNotEnabled:
                SensitiveAnalysisErrorView(retryAction: {
                    viewModel.resetImageStateToIdle()
                })
                
            case .error(let message):
                ErrorView(message: message,
                          refreshMessage: "Try again",
                          retryAction: {
                    viewModel.resetImageStateToIdle()
                }, systemImage: "xmark.circle.fill")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.2), value: viewModel.imageViewState)
    }
}

extension ImagePickerGridView {
    var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<10, id: \.self) { index in
                    ImagePickerCell(viewModel: viewModel, index: index, number: index + 1)
                        .frame(width: 100, height: 100)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}


#Preview {
    ImagePickerGridView(viewModel: EditFormImageManager())
}




