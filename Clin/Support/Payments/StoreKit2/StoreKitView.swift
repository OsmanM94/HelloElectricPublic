//
//  PromoteListingSection.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI
import StoreKit

struct StoreKitView: View {
    @State private var viewModel = StoreKitViewModel()
    
    @State private var showPayment: Bool = false
    @Binding var isPromoted: Bool
    var onPromotionSuccess: () -> Void
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text("Promote Listing")
                    .font(.headline)
                
                if isPromoted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Promotion added.")
                    }
                    .foregroundStyle(.tabColour)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What you get:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            BenefitRow(icon: "arrow.up.circle.fill", text: "Listing appears at the top (nationwide)")
                            BenefitRow(icon: "heart.fill", text: "Special favourite button")
                            BenefitRow(icon: "square.grid.3x3.fill", text: "Exclusive layout")
                        }
                        
                        HStack {
                            Text("£14.99")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("for 2 weeks")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Button {
                        showPayment.toggle()
                    } label: {
                        Text("Promote")
                            .bold()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(height: 45)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .task {
                await viewModel.loadProducts()
            }
            .listRowInsets(EdgeInsets())
            .padding()
        }
        .sheet(isPresented: $showPayment) {
            StoreKitPayWall(viewModel: viewModel, isPromoted: $isPromoted, onPromotionSuccess: onPromotionSuccess)
                .presentationDetents([.height(500)])
                .presentationDragIndicator(.visible)
        }
    }
}

fileprivate struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.tabColour)
                .frame(width: 20)
            Text(text)
        }
    }
}

fileprivate struct StoreKitPayWall: View {
    @Bindable var viewModel: StoreKitViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Binding var isPromoted: Bool
    var onPromotionSuccess: () -> Void
    @State private var termsAcknowledged: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .ready:
                    readyView
                    
                case .purchasing:
                    storeKitProgressView
                    
                case .completed:
                    completedView
                    
                case .failed(let message):
                    failedView(error: message)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .toolbar { toolbarView }
        }
    }
    
    private var readyView: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("Boost your visibility")
                .font(.title2)
                .bold()
            
            if let product = viewModel.product {
                CustomProductView(product: product)
                    .padding(.horizontal)
                
                PaymentDisclaimer(termsAcknowledged: $termsAcknowledged)
                
                Button(action: {
                    Task { await viewModel.purchase() }
                }) {
                    Text("Promote Now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(termsAcknowledged ? .primary : .secondary)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(!termsAcknowledged)
            } else {
                ProgressView("Please wait...")
                    .scaleEffect(1.5)
            }
        }
        .fontDesign(.rounded)
        .padding()
    }
    
    private var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.tabColour)
                .font(.system(size: 50))
            
            Text("Purchase successful!")
                .font(.title2)
                .fontWeight(.bold)
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tabColour.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
        }
        .fontDesign(.rounded)
        .padding()
        .onAppear {
            isPromoted = true
            onPromotionSuccess()
        }
    }
    
    private func failedView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.gray)
                .font(.system(size: 50))
            
            Text("Purchase Failed")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(error)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task { await viewModel.purchase() }
            }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tabColour.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
            .disabled(viewModel.viewState == .purchasing)
        }
        .fontDesign(.rounded)
        .padding()
    }
    
    private var storeKitProgressView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(2)
            
            Text("Processing your purchase...")
                .font(.headline)
        }
        .fontDesign(.rounded)
        .padding()
    }
    
    private var toolbarView: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray.opacity(0.8))
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.viewState == .purchasing)
        }
    }
    
    fileprivate struct CustomProductView: View {
        let product: Product
        
        var body: some View {
            VStack(spacing: 12) {
                Text(product.displayName)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(product.displayPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.tabColour)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .padding(.horizontal, 25)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}


#Preview {
    StoreKitView(isPromoted: .constant(false), onPromotionSuccess: { })
}
