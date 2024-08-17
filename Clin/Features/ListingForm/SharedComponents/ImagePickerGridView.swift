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
    @ObservedObject var viewModel: ViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            switch viewModel.imageViewState {
            case .idle:
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
            case .sensitiveContent(let message):
                ErrorView(message: message, retryAction: {
                    viewModel.resetStateToIdle()
                })
                
            case .sensitiveApiNotEnabled:
                SensitiveAnalysisErrorView(retryAction: {
                    viewModel.resetStateToIdle()
                })
                
            case .error(let message):
                ErrorView(message: message, retryAction: {
                    viewModel.resetStateToIdle()
                })
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.imageViewState)
    }
}


#Preview {
    ImagePickerGridView(
        viewModel: EditFormViewModel(
            listingService: MockListingService(),
            imageManager: MockImageManager(isHeicSupported: true),
            prohibitedWordsService: MockProhibitedWordsService(
                prohibitedWords: [""]),
            httpDownloader: MockHTTPDataDownloader()
        )
    )
}




