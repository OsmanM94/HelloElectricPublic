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

struct ImagePickerGridView<ViewModel: ImageManagerFormProtocol>: View {
    @State var viewModel: ViewModel
    @State private var draggedItem: SelectedImage?
    @State private var dragDropTip = DragDropImageTip()
    
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
        VStack {
            CustomTipView(tip: dragDropTip)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                        ImagePickerCell(viewModel: viewModel, index: index, number: index + 1)
                            .frame(width: 100, height: 100)
                            .onDrag {
                                self.draggedItem = image
                                return NSItemProvider(object: String(image?.id ?? UUID().uuidString) as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(item: image, items: $viewModel.selectedImages, draggedItem: $draggedItem, imageManager: viewModel, dragDropTip: dragDropTip))
                            .sensoryFeedback(.impact, trigger: draggedItem)
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
        }
    }
}

fileprivate struct DropViewDelegate: DropDelegate {
    let item: SelectedImage?
    @Binding var items: [SelectedImage?]
    @Binding var draggedItem: SelectedImage?
    
    var imageManager: ImageManagerFormProtocol
    var dragDropTip: DragDropImageTip

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem,
              let fromIndex = items.firstIndex(where: { $0?.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0?.id == item?.id }) else {
            return false
        }
        
        if fromIndex != toIndex {
            withAnimation {
                items.swapAt(fromIndex, toIndex)
            }
            imageManager.updateAfterReorder()
            
            Task {
                dragDropTip.invalidate(reason: .actionPerformed)
            }
        }

        self.draggedItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}


#Preview {
    ImagePickerGridView(viewModel: EditFormImageManager())
}




