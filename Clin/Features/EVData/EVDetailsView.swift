//
//  EVDetailsView.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import SwiftUI

struct EVDetailsView: View {
    let evData: EVDatabase
    
    @State private var expandedTerms: Set<String> = []
    @State private var showGlossary: Bool = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                imageCarousel
                
                Group {
                    performanceSection
                    rangeSection
                    batterySection
                    chargingSection
                    dimensionsSection
                    towingSection
                    efficiencySection
                    miscellaneousSection
                }
                .padding(.horizontal)
                
                legendSection
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("EV Terms") {
                    showGlossary.toggle()
                }
            }
        }
        .sheet(isPresented: $showGlossary) {
            EVGlossaryView()
        }
    }
    
    private var imageCarousel: some View {
        Group {
            if let images = evData.image1, !images.isEmpty {
                TabView {
                    ForEach(images, id: \.self) { imageURL in
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .containerRelativeFrame([.horizontal, .vertical]) { width, axis in
                    axis == .horizontal ? width : width * 0.50
                }
            } else {
                noImagesAvailable
            }
        }
    }
    
    private var noImagesAvailable: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 300)
            .overlay(
                Text("No images available")
                    .foregroundColor(.secondary)
            )
    }
    
    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Performance")
            
            infoRow("Acceleration (0-62 mph)", evData.performanceAcceleration0_62_Mph)
            infoRow("Top Speed", evData.performanceTopSpeed)
            infoRow("Total Power", evData.totalPower)
            infoRow("Torque", evData.performanceTorque)
            infoRow("Drive", evData.drive)
        }
    }
    
    private var rangeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Range")
            
            infoRow("Electric Range", evData.electricRange)
            infoRow("City (Cold)", evData.rangeCityCold)
            infoRow("Highway (Cold)", evData.rangeHighwayCold)
            infoRow("Combined (Cold)", evData.rangeCombinedCold)
            infoRow("City (Mild)", evData.rangeCityMild)
            infoRow("Highway (Mild)", evData.rangeHighwayMild)
            infoRow("Combined (Mild)", evData.rangeCombinedMild)
        }
    }
    
    private var batterySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Battery")
            
            infoRow("Nominal Capacity", evData.batteryNominalCapacity)
            infoRow("Useable Capacity", evData.batteryUseableCapacity)
            infoRow("Type", evData.batteryType)
            infoRow("Cells", evData.numberOfCells)
            infoRow("Architecture", evData.batteryArchitecture)
            infoRow("Cathode Material", evData.batteryCathodeMaterial)
            infoRow("Pack Configuration", evData.batteryPackConfiguration)
            infoRow("Nominal Voltage", evData.batteryNominalVoltage)
            infoRow("Form Factor", evData.batteryFormFactor)
            infoRow("Name", evData.batteryName)
            infoRow("Warranty", evData.batteryWarranty)
            infoRow("Warranty Mileage", evData.warrantyMileage)
        }
    }
    
    private var chargingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Charging")
            
            Group {
                infoRow("Home Port", evData.chargingHomePort)
                infoRow("Home Port Location", evData.chargingHomePortLocation)
                infoRow("Home Charge Power", evData.chargingHomeChargePower)
                infoRow("Home Charge Time", evData.chargingHomeChargeTime)
                infoRow("Home Charge Speed", evData.chargingHomeChargeSpeed)
                infoRow("Home Charge Power Max", evData.chargingHomeChargePowerMax)
                infoRow("Home Autocharge Supported", evData.chargingHomeAutochargeSupported)
            }
            
            Group {
                infoRow("Rapid Port", evData.chargingRapidPort)
                infoRow("Rapid Port Location", evData.chargingRapidPortLocation)
                infoRow("Rapid Charge Speed", evData.chargingRapidChargeSpeed)
                infoRow("Rapid Autocharge Supported", evData.chargingRapidAutochargeSupported)
            }
        }
    }
    
    private var dimensionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Dimensions & Weight")
            
            infoRow("Length", evData.dimensionsAndWeightLenght)
            infoRow("Width", evData.dimensionsAndWeightWidth)
            infoRow("Width (with mirrors)", evData.dimensionsAndWeightWidthMirrors)
            infoRow("Wheelbase", evData.dimensionsAndWeightWheelbase)
            infoRow("Weight (Unladen)", evData.dimensionsAndWeightWeightUnladen)
            infoRow("Gross Weight", evData.dimensionsGrossWeight)
            infoRow("Payload", evData.dimensionsPayload)
            infoRow("Cargo Volume", evData.dimensionsCargoVolume)
            infoRow("Max Cargo Volume", evData.dimensionsCargoVolumeMax)
            infoRow("Roof Load", evData.dimensionsRoofLoad)
        }
    }
        
        private var towingSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Towing")
                
                infoRow("Towing Capability", evData.dimensionsTow)
                infoRow("Towing Unbraked", evData.dimensionsTowingUnbraked)
                infoRow("Towing Braked", evData.dimensionsTowingBraked)
            }
        }
        
        private var efficiencySection: some View {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Efficiency")
                
                infoRow("Real Range Consumption", evData.efficiencyRealRangeConsumption)
                infoRow("Fuel Equivalent", evData.efficiencyFuelEquivalent)
            }
        }
        
        private var miscellaneousSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Miscellaneous")
                
                infoRow("Seats", evData.miscellaneousSeats)
                infoRow("Turning Circle", evData.miscellaneousTurningCircle)
                infoRow("Platform", evData.miscellaneousPlatform)
                infoRow("Body", evData.miscellaneousBody)
                infoRow("Segment", evData.miscellaneousSegment)
                infoRow("Roof Rails", evData.miscellaneousRoofRails)
                infoRow("Heat Pump", evData.miscellaneousHeatPump)
                infoRow("HP Standard Equipment", evData.miscellaneousHPStandardEquipment)
                infoRow("Available to Order From", evData.availableOrderFrom)
                infoRow("First Delivery Expected", evData.firstDeliveryExpected)
            }
        }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontDesign(.rounded)
            .bold()
            .padding(.vertical, 5)
    }
    
    private func infoRow(_ title: String, _ value: String?) -> some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value ?? "N/A")
                .foregroundStyle(.secondary)
        }
    }
    
    private var legendSection: some View {
           VStack(alignment: .leading, spacing: 15) {
               Text("Legend")
                   .font(.title2)
                   .fontWeight(.bold)
               
               ForEach(termExplanations, id: \.term) { termExplanation in
                   legendRow(for: termExplanation)
               }
           }
           .padding()
           .background(Color(.systemBackground))
           .clipShape(RoundedRectangle(cornerRadius: 10))
           .shadow(radius: 1)
           .padding()
       }
       
       private func legendRow(for termExplanation: TermExplanation) -> some View {
           VStack(alignment: .leading, spacing: 5) {
               HStack {
                   Text(termExplanation.term)
                       .font(.headline)
                   
                   Spacer()
                   
                   Image(systemName: "questionmark.circle")
                       .foregroundStyle(.blue)
                       .onTapGesture {
                           withAnimation {
                               if expandedTerms.contains(termExplanation.term) {
                                   expandedTerms.remove(termExplanation.term)
                               } else {
                                   expandedTerms.insert(termExplanation.term)
                               }
                           }
                       }
               }
               
               if expandedTerms.contains(termExplanation.term) {
                   Text(termExplanation.explanation)
                       .font(.subheadline)
                       .foregroundColor(.secondary)
                       .padding(.top, 5)
                       .transition(.opacity)
               }
           }
       }
}

struct TermExplanation {
    let term: String
    let explanation: String
}

let termExplanations: [TermExplanation] = [
    TermExplanation(term: "Segment", explanation: "The market segment the vehicle belongs to (e.g., A: mini cars, B: small cars, C: medium cars, D: large cars, E: executive cars, F: luxury cars)."),
    TermExplanation(term: "Heat Pump", explanation: "An energy-efficient heating and cooling system that transfers heat instead of generating it, improving the vehicle's range in cold weather."),
    TermExplanation(term: "Turning Circle", explanation: "The diameter of the smallest circular turn that the car is capable of making."),
    // Add more term explanations here...
]

struct EVGlossaryView: View {
    var body: some View {
        
            List(termExplanations, id: \.term) { termExplanation in
                VStack(alignment: .leading) {
                    Text(termExplanation.term)
                        .font(.headline)
                    Text(termExplanation.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Glossary")
        
    }
}

#Preview {
    NavigationStack {
        EVDetailsView(
            evData: EVDatabase(
                availability: "Available",
                availableSince: "2024",
                rangeCityCold: "300 km",
                rangeHighwayCold: "250 km",
                rangeCombinedCold: "275 km",
                rangeCityMild: "350 km",
                rangeHighwayMild: "300 km",
                rangeCombinedMild: "325 km",
                performanceAcceleration0_62_Mph: "7.5 sec",
                performanceTopSpeed: "180 km/h",
                electricRange: "510 km",
                totalPower: "150 kW",
                drive: "Rear Wheel Drive",
                batteryNominalCapacity: "77 kWh",
                batteryType: "Lithium-ion",
                numberOfCells: "288",
                batteryArchitecture: "Pouch",
                batteryWarranty: "8 years",
                warrantyMileage: "160,000 km",
                batteryUseableCapacity: "82 kWh",
                batteryCathodeMaterial: "NMC 811",
                batteryPackConfiguration: "12 modules, 24 cells each",
                batteryNominalVoltage: "352 V",
                batteryFormFactor: "Pouch",
                batteryName: "ID.4 Pro Battery",
                chargingHomePort: "Type 2",
                chargingHomePortLocation: "Right rear",
                chargingHomeChargePower: "11 kW AC",
                chargingHomeChargeTime: "7h 30min",
                chargingHomeChargeSpeed: "50 km/h",
                chargingHomeChargePowerMax: "11 kW",
                chargingHomeAutochargeSupported: "Yes",
                chargingRapidPort: "CCS",
                chargingRapidPortLocation: "Right rear",
                chargingRapidChargeSpeed: "550 km/h",
                chargingRapidAutochargeSupported: "Yes",
                efficiencyRealRangeConsumption: "18 kWh/100km",
                efficiencyFuelEquivalent: "2.0 L/100km",
                dimensionsAndWeightLenght: "4.58 m",
                dimensionsAndWeightWidth: "1.85 m",
                dimensionsAndWeightWidthMirrors: "2.11 m",
                dimensionsAndWeightWheelbase: "2.77 m",
                dimensionsAndWeightWeightUnladen: "2,124 kg",
                dimensionsGrossWeight: "2,660 kg",
                dimensionsPayload: "536 kg",
                dimensionsCargoVolume: "543 L",
                dimensionsCargoVolumeMax: "1,575 L",
                dimensionsRoofLoad: "75 kg",
                dimensionsTow: "Yes",
                dimensionsTowingUnbraked: "750 kg",
                dimensionsTowingBraked: "1,000 kg",
                miscellaneousSeats: "5",
                miscellaneousTurningCircle: "10.2 m",
                miscellaneousPlatform: "MEB",
                miscellaneousBody: "SUV",
                miscellaneousSegment: "D",
                miscellaneousRoofRails: "Optional",
                miscellaneousHeatPump: "Optional",
                miscellaneousHPStandardEquipment: "No",
                image1: [
                    "https://ev-database.org/img/auto/Volkswagen_ID4_2024/Volkswagen_ID4_2024-01@2x.jpg",
                    "https://ev-database.org/img/auto/Volkswagen_ID4_2024/Volkswagen_ID4_2024-02@2x.jpg"
                ],
                availableOrderFrom: "Now",
                firstDeliveryExpected: "Q1 2024",
                performanceTorque: "310 Nm",
                carName: "Volkswagen ID.4 (2024)",
                id: 1
            )
        )
    }
}
