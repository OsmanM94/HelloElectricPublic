//
//  EducationView.swift
//  Clin
//
//  Created by asia on 01/09/2024.
//

import SwiftUI

struct EducationCenterView: View {
    @State private var selectedSection: String?
    
    let sections = [
        ("Basics", [
            ("What is an Electric Vehicle?", "An Electric Vehicle (EV) is a car that uses one or more electric motors for propulsion. Instead of gasoline, EVs use electricity stored in rechargeable batteries to power the motor."),
            ("Types of EVs", "There are three main types of EVs:\n• Battery Electric Vehicles (BEVs): Fully electric, powered only by batteries.\n• Plug-in Hybrid Electric Vehicles (PHEVs): Can run on electricity for a limited range, then switch to gasoline.\n• Hybrid Electric Vehicles (HEVs): Use gasoline but have an electric motor to improve efficiency."),
            ("Key Components", "Main components of an EV include:\n• Electric Motor\n• Battery Pack\n• Inverter\n• Onboard Charger\n• Thermal System"),
            ("How EVs Work", "EVs work by using electricity stored in a battery pack to power an electric motor, which turns the wheels. When the battery is depleted, it can be recharged using a charging station or a home charger.")
        ]),
        ("Benefits", [
            ("Environmental Impact", "EVs produce zero direct emissions, reducing air pollution and greenhouse gases. Even when accounting for electricity generation, EVs typically have a lower carbon footprint than gasoline vehicles."),
            ("Lower Operating Costs", "EVs generally have lower fuel costs compared to gasoline vehicles. They also require less maintenance due to fewer moving parts and the absence of oil changes."),
            ("Performance Advantages", "EVs offer instant torque, providing quick acceleration. They also have a lower center of gravity, improving handling and stability."),
            ("Government Incentives", "Many governments offer incentives for EV purchases, including tax credits, rebates, and access to HOV lanes, making EVs more affordable and convenient.")
        ]),
        ("Ownership", [
            ("Range and Battery Management", "Modern EVs can typically travel 200-300 miles on a single charge. To maximize range:\n• Use regenerative braking\n• Avoid extreme temperatures\n• Maintain proper tire pressure\n• Plan your routes around charging stations"),
            ("Maintenance Tips", "EV maintenance is generally simpler than for gasoline cars:\n• Rotate tires regularly\n• Check brake fluid and coolant levels\n• Replace cabin air filter\n• Schedule battery checks"),
            ("Winter Driving", "Cold weather can reduce EV range. Tips for winter driving:\n• Precondition the battery while plugged in\n• Use seat heaters instead of cabin heater when possible\n• Keep the battery charge between 20% and 80%"),
            ("Resale Value", "EVs traditionally had lower resale values due to rapidly improving technology and battery concerns. However, this gap is narrowing as EVs become more mainstream and battery longevity improves.")
        ]),
        ("Charging Essentials", [
            ("Types of EV Chargers", "There are three main types of EV chargers:\n• Level 1 (120V AC): Standard household outlet, slowest charging\n• Level 2 (240V AC): Faster charging, common for home installation and public stations\n• Level 3 / DC Fast Charging: Fastest charging, typically found at public charging stations"),
            ("Home Charging Setup", "To set up home charging:\n1. Assess your electrical capacity\n2. Choose between a Level 1 or Level 2 charger\n3. Hire a licensed electrician for installation\n4. Consider smart chargers for scheduling and monitoring\n5. Check local regulations and incentives")
        ])
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(sections, id: \.0) { section in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { selectedSection == section.0 },
                            set: { _ in selectedSection = selectedSection == section.0 ? nil : section.0 }
                        ),
                        content: {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(section.1, id: \.0) { topic in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(topic.0)
                                            .font(.headline)
                                        Text(topic.1)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .padding(.vertical)
                        },
                        label: {
                            HStack {
                                Image(systemName: "bolt.circle.fill")
                                    .foregroundStyle(.green)
                                Text(section.0)
                                    .font(.title3.bold())
                            }
                        }
                    )
                    .padding(.vertical, 5)
                    
                    if section.0 != sections.last!.0 {
                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Education Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EducationCenterView()
    }
}
