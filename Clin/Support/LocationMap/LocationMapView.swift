//
//  LocationMapView.swift
//  Clin
//
//  Created by asia on 21/09/2024.
//

import SwiftUI
import MapKit

struct LocationMapView: View {
    let coordinate: CLLocationCoordinate2D
    
    @State private var region: MKCoordinateRegion
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))
    }
    
    var body: some View {
        Map(position: .constant(MapCameraPosition.region(region)) ) {
            MapCircle(center: coordinate, radius: 5000)
                .foregroundStyle(.blue.opacity(0.2))
                .stroke(.blue, lineWidth: 2)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    LocationMapView(coordinate: CLLocationCoordinate2DMake(100, 100))
}
