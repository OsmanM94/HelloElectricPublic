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
                    ForEach(viewModel.chargers, id: \.id) { charger in
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
                    VStack {
                        Text(charger.name)
                            .font(.headline)
                        Button("Open in Maps") {
                            viewModel.openInMaps(charger: charger)
                        }
                    }
                    .presentationDetents([.height(200)])
                }
                .onAppear {
                    CLLocationManager().requestWhenInUseAuthorization()
                }
                .onMapCameraChange { context in
                    Task {
                        await viewModel.fetchChargers(in: context.region)
                    }
                }
                .navigationBarBackButtonHidden(true)
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .foregroundStyle(.white)
                        .padding()
                        .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    StationsView()
}

