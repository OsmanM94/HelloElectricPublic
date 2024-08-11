//
//  ListingViewPlaceholders.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//

import SwiftUI

struct ListingViewPlaceholder: View {
    @State private var isLoading: Bool = true
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            List(0 ..< 6) { item in
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                            .padding(.top, 5)
                    }
                }
                .padding(.leading, 5)
                .padding(.vertical, 10)
            }
            .navigationTitle("Listings")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .shimmer(when: $isLoading)
            .refreshable {
                await retryAction()
            }
            .searchable(text: .constant(""), placement:
                    .navigationBarDrawer(displayMode: .always))
        }
        .onDisappear {
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        ListingViewPlaceholder(retryAction: {})
    }
}

extension View {
    @ViewBuilder
    func shimmer(when isLoading: Binding<Bool>) -> some View {
        if isLoading.wrappedValue {
            self.modifier(Shimmer())
                .redacted(reason: isLoading.wrappedValue ? .placeholder : [])
        } else {
            self
        }
    }
}

public struct Shimmer: ViewModifier {
    @State private var isInitialState = true
    
    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: .init(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3))
                )
            )
            .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear {
                isInitialState = false
            }
    }
}
