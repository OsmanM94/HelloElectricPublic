//
//  EVStationsView.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import SwiftUI
import MapKit

struct StationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = StationViewModel()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var currentRegion: EquatableRegion?
    @State private var isMapLoaded: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Map(position: $cameraPosition, selection: $viewModel.selectedStation) {
                    UserAnnotation()
                    ForEach(viewModel.filteredStations, id: \.id) { station in
                        Marker(station.name, coordinate: station.coordinate)
                            .tag(station)
                            .tint(.green)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapScaleView()
                }
                .sheet(item: $viewModel.selectedStation) { station in
                    StationDetailView(station: station, viewModel: viewModel)
                        .presentationDetents([.height(220)])
                        .presentationDragIndicator(.visible)
                }
                .onAppear {
                    CLLocationManager().requestWhenInUseAuthorization()
                    withAnimation(.easeIn(duration: 1.0)) {
                        isMapLoaded = true
                    }
                }
                .onMapCameraChange() { context in
                    viewModel.isLoading = true
                    currentRegion = EquatableRegion(region: context.region)
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    viewModel.isLoading = false
                    Task.detached {
                        await viewModel.loadStationsDebounced(in: context.region)
                    }
                }
//                .task(id: currentRegion) {
//                    guard let region = currentRegion?.region else { return }
//                    viewModel.loadStationsDebounced(in: region)
//                }
                .opacity(isMapLoaded ? 1 : 0)
                .navigationBarBackButtonHidden(true)

                VStack {
                    backButton
                }
                .padding(.horizontal)
                
                VStack {
                    filterPicker
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
            }
            .frame(width: 50, height: 50)
            .background(Color(.secondarySystemBackground).opacity(0.8))
            .clipShape(Circle())
            .foregroundStyle(.green)
        }
        .disabled(viewModel.isLoading)
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.selectedFilter) {
            Text("All").tag(StationFilter.all)
            Text("Free").tag(StationFilter.free)
            Text("Rapid").tag(StationFilter.fast)
        }
        .pickerStyle(.menu)
        .background(Color(.secondarySystemBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

fileprivate struct StationDetailView: View {
    let station: Station
    @Bindable var viewModel: StationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(station.name)
                .font(.headline)
            
            operatorTag
            stationSpecs
            statusInfo
            typeInfo
        }
        .padding()
        .padding(.top, 20)
        .frame(maxWidth: .infinity , alignment: .leading)
        
        VStack(alignment: .center) {
            Button(action: { viewModel.openInMaps(station: station) }) {
                Label("Open in Maps", systemImage: "map.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.green.gradient.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var operatorTag: some View {
        Text(station.isPrivateOperator ? "Private Operator" : "Public Operator")
            .font(.subheadline)
            .foregroundStyle(station.isPrivateOperator ? .red : .green)
    }
    
    private var stationSpecs: some View {
        Group {
            if let stationSpecs = viewModel.stationSpecs(for: station) {
                Label(stationSpecs, systemImage: "ev.charger.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var statusInfo: some View {
        Group {
            if let statusTitle = viewModel.stationStatus(for: station) {
                Label("Status: \(statusTitle)", systemImage: "bolt.fill")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
        }
    }

    private var typeInfo: some View {
        Group {
            if let connection = viewModel.connectionType(for: station) {
                Label(" Type: \(connection)", systemImage: "ev.plug.dc.ccs1")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    StationView()
}


fileprivate struct EquatableRegion: Equatable {
    let region: MKCoordinateRegion
    
    static func == (lhs: EquatableRegion, rhs: EquatableRegion) -> Bool {
        lhs.region.center.latitude == rhs.region.center.latitude &&
        lhs.region.center.longitude == rhs.region.center.longitude &&
        lhs.region.span.latitudeDelta == rhs.region.span.latitudeDelta &&
        lhs.region.span.longitudeDelta == rhs.region.span.longitudeDelta
    }
}
