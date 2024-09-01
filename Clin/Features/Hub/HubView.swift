//
//  HubView.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import SwiftUI

struct HubView: View {
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            LazyVGrid(columns: gridItems, spacing: 20) {
                NavigationLink(destination: LazyView(ChartViewContainer())) {
                    HubItemView(title: "Statistics", imageName: "chart.pie.fill")
                }
                NavigationLink(destination: LazyView(NewsViewContainer())) {
                    HubItemView(title: "News", imageName: "newspaper.fill")
                }
                
                NavigationLink(destination: LazyView(StatioViewContainer())) {
                    HubItemView(title: "EV Stations", imageName: "ev.charger.fill")
                }
                
                NavigationLink(destination: LazyView(ShowroomContainer())) {
                    HubItemView(title: "EV Data", imageName: "bolt.car.fill")
                }
            }
            .padding()
            .padding(.bottom, 60)
            .navigationTitle("Hub")
        }
    }
}

// MARK: - Containers

fileprivate struct ChartViewContainer: View {
    var body: some View {
        ChartView()
            .navigationTitle("Registrations")
    }
}

fileprivate struct NewsViewContainer: View {
    var body: some View {
        NewsView()
            .navigationTitle("News")
    }
}

fileprivate struct StatioViewContainer: View {
    var body: some View {
        StationView()
    }
}

fileprivate struct ShowroomContainer: View {
    var body: some View {
        Showroom()
            .navigationTitle("Showroom")
    }
}

#Preview {
    HubView()
}

fileprivate struct HubItemView: View {
    let title: String
    let imageName: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .foregroundStyle(.green.gradient)
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
