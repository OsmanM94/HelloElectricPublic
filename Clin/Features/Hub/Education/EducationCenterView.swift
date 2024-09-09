//
//  EducationView.swift
//  Clin
//
//  Created by asia on 01/09/2024.
//

import SwiftUI

struct EducationCenterView: View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            LazyVGrid(columns: columns, spacing: 20) {
                NavigationLink(destination: LazyView(BasicsView())) {
                    EducationItemView(title: "EV Basics", imageName: "bolt.car.fill")
                }
                NavigationLink(destination: LazyView(BenefitsView())) {
                    EducationItemView(title: "EV Benefits", imageName: "leaf.fill")
                }
                
                NavigationLink(destination: LazyView(OwnershipView())) {
                    EducationItemView(title: "EV Ownership", imageName: "key.fill")
                }
                
                NavigationLink(destination: LazyView(ChargingEssentialsView())) {
                    EducationItemView(title: "Charging Essentials", imageName: "ev.charger.fill")
                }
            }
            .padding()
            .padding(.bottom, 60)
        }
    }
}

fileprivate struct EducationItemView: View {
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

struct ContentListView: View {
    let title: String
    let content: [(String, String)]
    
    var body: some View {
        List(content, id: \.0) { item in
            VStack(alignment: .leading, spacing: 10) {
                Text(item.0).font(.system(size: 20, weight: .bold, design: .rounded))
                Text(item.1)
                    .foregroundStyle(.secondary)
                    .lineSpacing(5)
            }
            .listRowSeparator(.hidden, edges: .all)
            .padding(.vertical)
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BasicsView: View {
    static let basics = [
        ("What is an Electric Vehicle?", "An Electric Vehicle (EV) is a car that uses one or more electric motors for propulsion. Instead of gasoline, EVs use electricity stored in rechargeable batteries to power the motor."),
        ("Types of EVs", "There are three main types of EVs:\n• Battery Electric Vehicles (BEVs): Fully electric, powered only by batteries.\n• Plug-in Hybrid Electric Vehicles (PHEVs): Can run on electricity for a limited range, then switch to gasoline.\n• Hybrid Electric Vehicles (HEVs): Use gasoline but have an electric motor to improve efficiency."),
        ("Key Components", "Main components of an EV include:\n• Electric Motor\n• Battery Pack\n• Inverter\n• Onboard Charger\n• Thermal System"),
        ("How EVs Work", "EVs work by using electricity stored in a battery pack to power an electric motor, which turns the wheels. When the battery is depleted, it can be recharged using a charging station or a home charger.")
    ]
    
    var body: some View {
        ContentListView(title: "EV Basics", content: Self.basics)
    }
}

struct BenefitsView: View {
    static let benefits = [
        ("Environmental Impact", "EVs produce zero direct emissions, reducing air pollution and greenhouse gases. Even when accounting for electricity generation, EVs typically have a lower carbon footprint than gasoline vehicles."),
        ("Lower Operating Costs", "EVs generally have lower fuel costs compared to gasoline vehicles. They also require less maintenance due to fewer moving parts and the absence of oil changes."),
        ("Performance Advantages", "EVs offer instant torque, providing quick acceleration. They also have a lower center of gravity, improving handling and stability."),
        ("Government Incentives", "Many governments offer incentives for EV purchases, including tax credits, rebates, and access to HOV lanes, making EVs more affordable and convenient.")
    ]
    
    var body: some View {
        ContentListView(title: "EV Benefits", content: Self.benefits)
    }
}

struct OwnershipView: View {
    static let ownership = [
        ("Range and Battery Management", "Modern EVs can typically travel 200-300 miles on a single charge. To maximize range:\n• Use regenerative braking\n• Avoid extreme temperatures\n• Maintain proper tire pressure\n• Plan your routes around charging stations"),
        ("Maintenance Tips", "EV maintenance is generally simpler than for gasoline cars:\n• Rotate tires regularly\n• Check brake fluid and coolant levels\n• Replace cabin air filter\n• Schedule battery checks"),
        ("Winter Driving", "Cold weather can reduce EV range. Tips for winter driving:\n• Precondition the battery while plugged in\n• Use seat heaters instead of cabin heater when possible\n• Keep the battery charge between 20% and 80%"),
        ("Resale Value", "EVs traditionally had lower resale values due to rapidly improving technology and battery concerns. However, this gap is narrowing as EVs become more mainstream and battery longevity improves.")
    ]
    
    var body: some View {
        ContentListView(title: "EV Ownership", content: Self.ownership)
    }
}

struct ChargingEssentialsView: View {
    static let charging = [
        ("Types of EV Chargers", "There are three main types of EV chargers:\n• Level 1 (120V AC): Standard household outlet, slowest charging\n• Level 2 (240V AC): Faster charging, common for home installation and public stations\n• Level 3 / DC Fast Charging: Fastest charging, typically found at public charging stations"),
        ("Home Charging Setup", "To set up home charging:\n1. Assess your electrical capacity\n2. Choose between a Level 1 or Level 2 charger\n3. Hire a licensed electrician for installation\n4. Consider smart chargers for scheduling and monitoring\n5. Check local regulations and incentives")
    ]
    
    var body: some View {
        ContentListView(title: "Charging Essentials", content: Self.charging)
    }
}
#Preview {
    NavigationStack {
        EducationCenterView()
    }
}



