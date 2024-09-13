//
//  EVDetailsView.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import SwiftUI

struct EVDetailsView: View {
    let evData: EVDatabase
    
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
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Glossary") { showGlossary.toggle() }
            }
        }
        .sheet(isPresented: $showGlossary) {
            EVGlossaryView()
                .presentationDragIndicator(.visible)
        }
    }
    
    private var imageCarousel: some View {
        Group {
            if let images = evData.image1, !images.isEmpty {
                TabView {
                    ForEach(images, id: \.self) { imageURL in
                        ZoomImages {
                            ImageLoader(url: imageURL, contentMode: .fit, targetSize: CGSize(width: 350, height: 350))
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
                    .foregroundStyle(.secondary)
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
            .foregroundStyle(.green.gradient)
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
}

fileprivate struct TermExplanation {
    let term: String
    let explanation: String
}

fileprivate struct EVGlossaryView: View {
    let termExplanations: [TermExplanation] = [
        TermExplanation(term: "Segment", explanation: "The market segment the vehicle belongs to (e.g., A: mini cars, B: small cars, C: medium cars, D: large cars, E: executive cars, F: luxury cars)."),
        TermExplanation(term: "Heat Pump", explanation: "An energy-efficient heating and cooling system that transfers heat instead of generating it, improving the vehicle's range in cold weather."),
        TermExplanation(term: "Turning Circle", explanation: "The diameter of the smallest circular turn that the car is capable of making."),
        TermExplanation(term: "Cathode Material", explanation: "The material used in the cathode of the battery, which influences the battery's performance, longevity, and energy density."),
        TermExplanation(term: "Pouch Cell", explanation: "A type of battery cell design that uses a flexible outer layer, allowing for a lighter and more adaptable battery configuration."),
        TermExplanation(term: "Nominal Voltage", explanation: "The standard operating voltage of a battery pack under normal conditions."),
        TermExplanation(term: "Drive", explanation: "Refers to the drivetrain configuration of the vehicle, such as Front-Wheel Drive (FWD), Rear-Wheel Drive (RWD), or All-Wheel Drive (AWD)."),
        TermExplanation(term: "Battery Architecture", explanation: "The structural design of the battery pack, including how cells are arranged and connected."),
        TermExplanation(term: "Autocharge", explanation: "A feature allowing compatible charging stations to recognize the vehicle and initiate charging automatically without manual input."),
        TermExplanation(term: "Roof Load", explanation: "The maximum weight that can be safely carried on the vehicle's roof, typically when using roof racks."),
        TermExplanation(term: "Payload", explanation: "The total weight of passengers and cargo that the vehicle can carry, excluding its own weight."),
        TermExplanation(term: "Towing Capacity", explanation: "The maximum weight that the vehicle can tow, including both braked and unbraked trailers."),
        TermExplanation(term: "Fuel Equivalent", explanation: "A comparison of the vehicle's energy consumption with traditional fuel vehicles, expressed in liters per 100 miles."),
        TermExplanation(term: "Platform", explanation: "The underlying architecture or chassis that the vehicle is built on, often shared across multiple models within a manufacturer."),
        TermExplanation(term: "Nominal Capacity", explanation: "The total amount of energy that a battery can theoretically store, often measured in kilowatt-hours (kWh)."),
        TermExplanation(term: "Gross Weight", explanation: "The total weight of the vehicle including all passengers, cargo, and accessories when fully loaded."),
        TermExplanation(term: "Wheelbase", explanation: "The distance between the front and rear axles of the vehicle, affecting stability, handling, and interior space."),
        TermExplanation(term: "Charging Speed", explanation: "The rate at which the vehicle's battery is charged, usually measured in kilometers per hour (km/h) or kilowatts (kW)."),
        TermExplanation(term: "Battery Warranty", explanation: "The period or mileage for which the manufacturer guarantees the battery pack, typically covering defects and degradation below a certain level."),
        TermExplanation(term: "Pack Configuration", explanation: "The specific arrangement and grouping of battery cells within the pack, impacting overall performance and efficiency."),
        TermExplanation(term: "Cargo Volume", explanation: "The amount of storage space available in the vehicle's trunk or cargo area, measured in liters (L)."),
        TermExplanation(term: "Drive Modes", explanation: "Various settings that alter the vehicle's performance characteristics, such as efficiency, sport, or off-road modes."),
        TermExplanation(term: "Range", explanation: "The estimated distance the vehicle can travel on a full charge under specific conditions, such as city or highway driving."),
        TermExplanation(term: "Charging Ports", explanation: "Connectors used for recharging the vehicle's battery, with different standards like Type 2 or CCS offering varied charging speeds."),
        TermExplanation(term: "Torque", explanation: "A measure of rotational force, indicating the vehicle's ability to accelerate, especially from a standstill."),
        TermExplanation(term: "Form Factor", explanation: "The physical shape and size of the battery cells, which can influence how they fit into the battery pack and overall vehicle design."),
        TermExplanation(term: "Home Charging", explanation: "Charging the vehicle at home using a standard outlet or a dedicated home charger, usually at lower speeds compared to rapid charging stations.")
    ]
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            if isAnimating {
                List(termExplanations, id: \.term) { termExplanation in
                    VStack(alignment: .leading) {
                        Text(termExplanation.term)
                            .font(.headline)
                            .fontDesign(.rounded)
                            .bold()
                        Text(termExplanation.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                }
                .listStyle(.plain)
            } else {
                CustomProgressView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                withAnimation(.easeInOut) {
                    isAnimating = true
                }
            })
        }
    }
}

#Preview {
    NavigationStack {
        EVDetailsView(evData: EVDatabase.sampleData)
    }
}
