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
    @State private var selectedStation: Station?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Map(position: $cameraPosition, interactionModes: .all, selection: $selectedStation) {
                    UserAnnotation()
                    ForEach(viewModel.filteredStations, id: \.id) { station in
                        Marker(station.name, coordinate: station.coordinate)
                            .tag(station)
                            .tint(.green)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                    MapPitchToggle()
                }
                .sheet(item: $selectedStation) { station in
                    StationDetailView(station: station, viewModel: viewModel)
                        .presentationDetents([.height(210)])
                }
                .onAppear {
                    CLLocationManager().requestWhenInUseAuthorization()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    viewModel.isLoading = true
                    Task {
                        viewModel.loadStationsDebounced(in: context.region)
                    }
                }
                .navigationBarBackButtonHidden(true)

                VStack {
                    HStack {
                        backButton
                        Spacer()
                        filterPicker
                    }
                    Spacer()
                }
                .padding()
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
            .background(Color.gray.opacity(0.5))
            .clipShape(Circle())
            .foregroundStyle(.white)
        }
        .offset(x: 0, y: -15)
        .disabled(viewModel.isLoading)
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.selectedFilter) {
            Text("All").tag(StationFilter.all)
            Text("Free").tag(StationFilter.free)
            Text("Fast").tag(StationFilter.fast)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.trailing, 40)
        .offset(x: 0, y: -22)
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
            if let statusTitle = viewModel.statusTitle(for: station) {
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

