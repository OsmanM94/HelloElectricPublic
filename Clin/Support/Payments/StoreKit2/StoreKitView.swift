//
//  PromoteListingSection.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI
import StoreKit

struct StoreKitView: View {
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
                            .foregroundStyle(.green.gradient)
                        Text("Promoted.")
                        Spacer()
                        Text("Currently promoted.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What you get:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            BenefitRow(icon: "arrow.up.circle.fill", text: "Listing appears at the top (nationwide)")
                            BenefitRow(icon: "tag.fill", text: "Listing badge")
                            BenefitRow(icon: "square.grid.3x3.fill", text: "Exclusive layout")
                        }
                        
                        HStack {
                            Text("£13.99")
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
                        Text("Buy")
                            .foregroundStyle(.primary)
                            .bold()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(height: 45)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .listRowInsets(EdgeInsets())
            .padding()
        }
        .sheet(isPresented: $showPayment) {
            StoreKitPayWall(isPromoted: $isPromoted, onPromotionSuccess: onPromotionSuccess)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.green.gradient)
                .frame(width: 20)
            Text(text)
        }
    }
}

enum PurchaseViewState: Equatable {
    case ready
    case purchasing
    case completed
    case failed(String)
}

struct StoreKitPayWall: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPromoted: Bool
    @State private var product: Product?
    @State private var viewState: PurchaseViewState = .ready
    
    var onPromotionSuccess: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewState {
                case .ready:
                    readyView
                case .purchasing:
                    CustomProgressView()
                case .completed:
                    completedView
                case .failed(let message):
                    failedView(error: message)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewState)
            .onInAppPurchaseStart { product in
                viewState = .purchasing
                print("User has started buying \(product.id)")
            }
            .onInAppPurchaseCompletion { product, result in
                switch result {
                case .success(.success(let transaction)):
                    print("Purchased successfully: \(transaction.signedDate)")
                    isPromoted = true
                    onPromotionSuccess()
                    viewState = .completed
                case .success(.userCancelled):
                    print("User cancelled the purchase")
                    viewState = .ready
                case .success(.pending):
                    print("Purchase is pending")
                    viewState = .ready
                case .failure(let error):
                    print("Purchase failed: \(error.localizedDescription)")
                    viewState = .failed("Please try again.")
                @unknown default:
                    viewState = .failed("Please try again.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.8))
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewState == .purchasing)
                }
            }
        }
        .task {
            await loadProducts()
        }
    }
    
    private func loadProducts() async {
       do {
           let products = try await Product.products(for: ["promote2weeks"])
           if let product = products.first {
               self.product = product
           }
       } catch {
           print("Error loading products \(error)")
       }
   }
    
    private var readyView: some View {
        VStack {
            Text("Promote")
                .font(.title)
                .fontDesign(.rounded).bold()

            ProductView(id: "promote2weeks") {
                Image("electric-car")
                    .resizable()
                    .scaledToFit()
            }
            .productViewStyle(.compact)
            .padding()
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: 50))
            Text("Purchase Completed!")
                .font(.title2)
                .fontDesign(.rounded).bold()
        }
    }
    
    private func failedView(error: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.gray)
                .font(.system(size: 50))
            Text("Purchase Failed")
                .font(.title2)
                .fontDesign(.rounded).bold()
            Button("Try Again") {
                viewState = .ready
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding()
        }
    }
}

#Preview {
    StoreKitView(isPromoted: .constant(true), onPromotionSuccess: { })
}
