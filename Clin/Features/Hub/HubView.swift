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
                
                NavigationLink(destination: LazyView(EducationCenterContainer())) {
                    HubItemView(title: "Education", imageName: "book.fill")
                }
                
            }
            .padding()
            .navigationTitle("Hub")
            
            VStack(alignment: .leading) {
                Text("EV Database")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                
                Text("Browse electric vehicles, sourced directly from manufacturers, offering detailed information on models, specifications, and more.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                
                NavigationLink("Browse Database") {
                    LazyView(EVDatabaseContainer())
                }
                .padding(.top)
                .foregroundStyle(.tabColour)
            }
            .padding()
            .overlay(alignment: .topTrailing) {
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.tabColour.gradient)
                    .clipShape(Circle())
                    .padding()
            }
            .background(Color.lightGrayBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
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

fileprivate struct EducationCenterContainer: View {
    var body: some View {
        EducationCenterView()
            .navigationTitle("Education")
    }
}

fileprivate struct EVDatabaseContainer: View {
    var body: some View {
        EVListView()
            .navigationTitle("Database")
    }
}

#Preview {
    HubView()
}

fileprivate struct HubItemView: View {
    let title: String
    let imageName: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .foregroundStyle(.tabColour.gradient)
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color.lightGrayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
