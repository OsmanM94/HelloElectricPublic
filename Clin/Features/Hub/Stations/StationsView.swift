//
//  EVStationsView.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import SwiftUI
import MapKit

struct StationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = EVChargerMapViewModel()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedCharger: Station?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Map(position: $cameraPosition, interactionModes: .all, selection: $selectedCharger) {
                    UserAnnotation()
                    ForEach(viewModel.filteredChargers, id: \.id) { charger in
                        Marker(charger.name, coordinate: charger.coordinate)
                            .tag(charger)
                            .tint(.green)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                    MapPitchToggle()
                }
                .sheet(item: $selectedCharger) { charger in
                    ChargerDetailView(charger: charger, viewModel: viewModel)
                        .presentationDetents([.height(210)])
                }
                .onAppear {
                    CLLocationManager().requestWhenInUseAuthorization()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    viewModel.isLoading = true
                    Task {
                        viewModel.fetchChargersDebounced(in: context.region)
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
            Text("All").tag(ChargerFilter.all)
            Text("Free").tag(ChargerFilter.free)
            Text("Fast").tag(ChargerFilter.fast)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.trailing, 40)
        .offset(x: 0, y: -22)
    }
}

struct ChargerDetailView: View {
    let charger: Station
    @Bindable var viewModel: EVChargerMapViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(charger.name)
                .font(.headline)
            
            operatorTag
            stationSpecs
            statusInfo
            typeInfo
        }
        .padding()
        .frame(maxWidth: .infinity , alignment: .leading)
        
        VStack(alignment: .center) {
            Button(action: { viewModel.openInMaps(charger: charger) }) {
                Label("Open in Maps", systemImage: "map.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.green.gradient.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var operatorTag: some View {
        Text(charger.isPrivateOperator ? "Private Operator" : "Public Operator")
            .font(.subheadline)
            .foregroundStyle(charger.isPrivateOperator ? .red : .green)
    }
    
    private var stationSpecs: some View {
        Group {
            if let stationSpecs = viewModel.stationSpecs(for: charger) {
                Label(stationSpecs, systemImage: "ev.charger.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var statusInfo: some View {
        Group {
            if let statusTitle = viewModel.statusTitle(for: charger) {
                Label("Status: \(statusTitle)", systemImage: "bolt.fill")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
        }
    }

    private var typeInfo: some View {
        Group {
            if let connection = viewModel.connectionType(for: charger) {
                Label(" Type: \(connection)", systemImage: "ev.plug.dc.ccs1")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    StationsView()
}

