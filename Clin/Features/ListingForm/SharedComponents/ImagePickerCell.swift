//
//  ImagePickerCell.swift
//  Clin
//
import SwiftUI


struct ImagePickerCell<ViewModel: ImagePickerProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showDeleteAlert: Bool = false
    @State private var itemToDelete: SelectedImage?
    
    let index: Int
    let number: Int
    
    var body: some View {
        ZStack {
            Group {
                if let image = viewModel.selectedImages[index] {
                    if let uiImage = UIImage(data: image.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    itemToDelete = image
                                    showDeleteAlert = true
                                } label: {
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(.red.gradient)
                                            .frame(width: 20, height: 20)
                                            .clipShape(Circle())
                                        Image(systemName: "xmark")
                                            .foregroundStyle(.white)
                                            .imageScale(.small)
                                    }
                                }
                                .offset(x: 5, y: -6)
                            }
                    } else {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                } else {
                    SinglePhotoPicker(selection: $viewModel.imageSelections[index], photoLibrary: .shared()) {
                        ZStack {
                            if viewModel.isLoading[index] {
                                Color(.clear)
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                ProgressView()
                                    .scaleEffect(1.2)
                            } else {
                                Text("\(number)")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    } onSelect: { newPhoto in
                        if let item = newPhoto {
                            Task {
                                await viewModel.loadItem(item: item, at: index)
                            }
                        }
                    }
                    

                }
            }
            .disabled(viewModel.isLoading[index])
        }
        .deleteAlert(
            isPresented: $showDeleteAlert,
            itemToDelete: $itemToDelete
        ) { item in
             viewModel.deleteImage(id: item.id)
        }
    }
}

#Preview {
    ImagePickerCell(viewModel: EditFormViewModel(), index: 1, number: 1)
    .preferredColorScheme(.dark)
}
