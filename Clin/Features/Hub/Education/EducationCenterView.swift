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

fileprivate struct ContentListView: View {
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

fileprivate struct BasicsView: View {
    static let basics = [
        ("What is an Electric Vehicle?", "An Electric Vehicle (EV) is a car that uses one or more electric motors for propulsion. Instead of gasoline, EVs use electricity stored in rechargeable batteries to power the motor. EVs are part of a growing trend towards more sustainable and environmentally friendly transportation. They offer several advantages over traditional internal combustion engine vehicles, including lower emissions, reduced operating costs, and often better performance in terms of acceleration and torque."),
        ("Types of EVs", "There are three main types of EVs:\n• Battery Electric Vehicles (BEVs): Fully electric, powered only by batteries. Examples include Tesla Model 3, Nissan Leaf, and Chevrolet Bolt. BEVs produce zero direct emissions and typically have the longest electric-only range.\n• Plug-in Hybrid Electric Vehicles (PHEVs): Can run on electricity for a limited range, then switch to gasoline. Examples include Toyota Prius Prime and Chevrolet Volt. PHEVs offer the flexibility of using either electricity or gasoline, making them a good transition option for those concerned about range.\n• Hybrid Electric Vehicles (HEVs): Use gasoline but have an electric motor to improve efficiency. Examples include Toyota Prius and Honda Insight. HEVs don't plug in to charge; instead, they recover energy through regenerative braking and by capturing power from the gasoline engine."),
        ("Key Components", "Main components of an EV include:\n• Electric Motor: Converts electrical energy into mechanical energy to drive the wheels. EVs can have one or multiple motors.\n• Battery Pack: Stores electrical energy to power the motor. Usually lithium-ion batteries, they are the most expensive component of an EV.\n• Inverter: Converts the DC power from the battery to AC power for the motor, and vice versa during regenerative braking.\n• Onboard Charger: Converts AC power from the grid to DC power to charge the battery.\n• Thermal System: Manages the temperature of the battery, motor, and electronics to ensure optimal performance and longevity.\n• Power Electronics Controller: Acts as the 'brain' of the system, managing the flow of electrical energy between the battery and motor."),
        ("How EVs Work", "EVs work by using electricity stored in a battery pack to power an electric motor, which turns the wheels. Here's a more detailed breakdown:\n1. The battery pack provides DC power to the inverter.\n2. The inverter converts DC to AC power for the electric motor.\n3. The electric motor uses this power to drive the wheels, providing instant torque and smooth acceleration.\n4. When braking or coasting, the motor can act as a generator, converting kinetic energy back into electricity (regenerative braking) to recharge the battery.\n5. When the battery is depleted, it can be recharged using a charging station or a home charger.\n6. The power electronics controller manages this entire process, ensuring efficient operation.\n\nUnlike internal combustion engines, electric motors provide instant torque, resulting in quick acceleration. They're also much more efficient, converting about 77% of electrical energy to power at the wheels, compared to about 12-30% for gasoline engines.")
    ]
    
    var body: some View {
        ContentListView(title: "EV Basics", content: Self.basics)
    }
}

fileprivate struct BenefitsView: View {
    static let benefits = [
        ("Environmental Impact", "EVs produce zero direct emissions, reducing air pollution and greenhouse gases. Even when accounting for electricity generation, EVs typically have a lower carbon footprint than gasoline vehicles. Here's why:\n• Efficiency: EVs convert about 77% of electrical energy to power at the wheels, compared to 12-30% for gasoline engines.\n• Renewable Energy: As the grid becomes cleaner with more renewable energy sources, the carbon footprint of EVs continues to decrease.\n• Lifecycle Emissions: While battery production does have environmental impacts, studies show that EVs make up for this within 6-18 months of average driving.\n• Air Quality: EVs help improve local air quality, especially in urban areas, reducing health issues related to air pollution.\n• Noise Pollution: EVs are much quieter than traditional vehicles, helping to reduce noise pollution in cities."),
        ("Lower Operating Costs", "EVs generally have lower fuel costs compared to gasoline vehicles. They also require less maintenance due to fewer moving parts and the absence of oil changes. Here's a breakdown:\n• Fuel Costs: Electricity is generally cheaper than gasoline. The cost to drive an EV is about one-third to one-half the cost of driving a gasoline car.\n• Maintenance: EVs have fewer moving parts and fluids to change. No oil changes, spark plugs, or timing belts to replace.\n• Brakes: Regenerative braking in EVs reduces wear on brake pads, extending their life.\n• Incentives: Many utility companies offer lower rates for EV charging during off-peak hours.\n• Long-term Savings: While EVs may have a higher upfront cost, the total cost of ownership over the life of the vehicle is often lower than comparable gasoline vehicles."),
        ("Performance Advantages", "EVs offer instant torque, providing quick acceleration. They also have a lower center of gravity, improving handling and stability. Other performance benefits include:\n• Smooth and Quiet Ride: Electric motors provide smooth acceleration without gear changes, and operate much more quietly than combustion engines.\n• Better Traction Control: The responsiveness of electric motors allows for more precise traction control systems.\n• Regenerative Braking: This feature not only increases efficiency but also reduces brake wear and can improve handling in certain conditions.\n• Low Center of Gravity: The heavy battery pack is usually mounted low in the vehicle, improving stability and reducing the risk of rollover.\n• All-Wheel Drive: Dual-motor EVs can provide true all-wheel drive with independent control of front and rear axles, improving handling and traction."),
        ("Energy Independence", "Widespread adoption of EVs can help reduce a country's dependence on imported oil, improving energy security and reducing exposure to oil price volatility. This can have significant economic and geopolitical benefits.")
    ]
    
    var body: some View {
        ContentListView(title: "EV Benefits", content: Self.benefits)
    }
}

fileprivate struct OwnershipView: View {
    static let ownership = [
        ("Range and Battery Management", "Modern EVs can typically travel 200-300 miles on a single charge, with some models exceeding 400 miles. To maximize range:\n• Use regenerative braking: This captures energy typically lost during braking and uses it to recharge the battery.\n• Avoid extreme temperatures: Both very hot and very cold weather can reduce battery efficiency. Use climate control sparingly or precondition the car while it's still plugged in.\n• Maintain proper tire pressure: Underinflated tires increase rolling resistance and reduce range.\n• Plan your routes around charging stations: Use the Station finder from our app or your car's built-in navigation to find charging stations along your route.\n• Practice efficient driving: Smooth acceleration and deceleration, and maintaining a steady speed can significantly improve range.\n• Minimize use of auxiliary power: Features like heated seats and air conditioning can drain the battery quickly.\n• Keep your EV's software updated: Manufacturers often push updates that can improve battery management and efficiency."),
        ("Maintenance Tips", "EV maintenance is generally simpler than for gasoline cars, but there are still important tasks:\n• Rotate tires regularly: EVs' instant torque can cause faster tire wear.\n• Check brake fluid and coolant levels: While used less, these systems still require maintenance.\n• Replace cabin air filter: This should be done according to the manufacturer's schedule.\n• Schedule battery checks: Have the battery health checked periodically, especially as the vehicle ages.\n• Keep the battery at an optimal charge level: For daily use, keeping the battery between 20% and 80% charge can help prolong its life.\n• Clean battery contacts: If applicable, keep the battery contacts clean to ensure efficient charging.\n• Check and replace wiper blades as needed.\n• Maintain the brake system: Despite less wear due to regenerative braking, regular brake service is still important.\n• Keep the exterior clean: Regular washing can prevent build-up of corrosive materials, especially in areas with road salt."),
        ("Winter Driving", "Cold weather can reduce EV range by 20-40%. Tips for winter driving:\n• Precondition the battery while plugged in: Warm up the car and battery before unplugging to save range.\n• Use seat heaters instead of cabin heater when possible: They use less energy.\n• Keep the battery charge between 20% and 80%: This helps maintain battery health in cold weather.\n• Use eco mode: This can help extend range by limiting power output.\n• Park in a garage if possible: This helps keep the battery warmer.\n• Use a lower regenerative braking setting: This can help with traction on slippery roads.\n• Plan for longer charging times: Cold batteries charge more slowly.\n• Consider winter tires: They can improve traction and safety in snow and ice.\n• Keep your charge port and cable clean and dry to prevent freezing."),
        ("Resale Value", "EVs traditionally had lower resale values due to rapidly improving technology and battery concerns. However, this gap is narrowing as EVs become more mainstream and battery longevity improves. Factors affecting EV resale value include:\n• Battery Health: The condition of the battery is crucial. Many EVs now come with long battery warranties, which can transfer to subsequent owners.\n• Technology: EVs with more advanced features and longer range tend to hold their value better.\n• Brand Reputation: Some EV brands, like Tesla, have shown strong resale values.\n• Government Incentives: The availability of incentives for new EVs can affect the used EV market.\n• Market Demand: As more consumers become interested in EVs, demand for used EVs is increasing.\n• Charging Infrastructure: Growth in charging networks is making EVs more practical, potentially boosting resale values.\n• Improvements in newer models: Rapid advancements in range and features can make older models less desirable, but this is starting to stabilize."),
        ("Insurance Considerations", "Insuring an EV can be different from insuring a traditional vehicle:\n• Higher Premiums: EVs often have higher insurance premiums due to higher repair and replacement costs.\n• Specialized Coverage: Some insurers offer specialized coverage for EV batteries and charging equipment.\n• Discounts: Many insurers offer discounts for eco-friendly vehicles, which can help offset higher base premiums.\n• Charging Station Liability: Consider whether your policy covers incidents related to your home charging station.")
    ]
    
    var body: some View {
        ContentListView(title: "EV Ownership", content: Self.ownership)
    }
}

fileprivate struct ChargingEssentialsView: View {
    static let charging = [
        ("Types of EV Chargers", "There are three main types of EV chargers:\n• Level 1 (120V AC): Standard household outlet, slowest charging\n  - Typical charging rate: 2-5 miles of range per hour\n  - Best for: Overnight charging at home for PHEVs or short-range EVs\n  - No additional equipment needed\n• Level 2 (240V AC): Faster charging, common for home installation and public stations\n  - Typical charging rate: 10-60 miles of range per hour\n  - Best for: Home charging for most EVs, workplace charging\n  - Requires special installation but widely available\n• Level 3 / DC Fast Charging: Fastest charging, typically found at public charging stations\n  - Typical charging rate: 3-20 miles of range per minute\n  - Best for: Long-distance travel, quick top-ups\n  - Not typically installed at homes due to high power requirements and cost\n\nCharging Connectors:\n• J1772: Standard for Level 1 and Level 2 charging in North America\n• CCS (Combined Charging System): Combines J1772 with DC fast charging\n• CHAdeMO: Another DC fast charging standard, less common in newer non-Japanese EVs\n• Tesla: Proprietary connector for Tesla vehicles (adapters available for other standards)"),

        ("Home Charging Setup", "To set up home charging:\n1. Assess your electrical capacity: Determine if your home's electrical system can support a Level 2 charger (usually requires a 240V, 40-50 amp circuit).\n2. Choose between a Level 1 or Level 2 charger: Consider your daily driving needs and how quickly you need to charge.\n3. Hire a licensed electrician for installation: They can ensure proper installation and compliance with local codes.\n4. Consider smart chargers: These allow for scheduling and monitoring of your charging, often through a smartphone app.\n5. Check local regulations and incentives: Some areas require permits for installation, and many offer rebates or tax incentives for home charger installation.\n6. Placement: Choose a convenient location, considering cable length and proximity to your parking spot.\n7. Future-proofing: Consider installing a higher amperage circuit than currently needed to accommodate future EVs with larger batteries.\n8. Outdoor considerations: If installing outdoors, ensure the charger and outlet are rated for outdoor use and protected from the elements."),

        ("Public Charging Networks", "Understanding public charging networks is crucial for long-distance travel and charging away from home:\n• Major Networks: Familiarize yourself with networks like our built-in Station finder and Tesla Superchargers (for Tesla vehicles), or your vehicle's built-in system to locate charging stations.\n• Payment Methods: Many networks require an account or app for payment, while some allow credit card payments at the station.\n• Charging Etiquette: Be mindful of other EV owners – move your vehicle once charging is complete, and don't unplug other vehicles unless it's clear they've finished charging.\n• Reliability: Check user reviews and real-time availability of charging stations before relying on them for a trip.\n• Charging Speed: Not all chargers in a network charge at the same speed. Look for kilowatt (kW) ratings to understand charging speeds."),

        ("Workplace Charging", "Workplace charging is becoming increasingly common and can be a significant benefit for EV owners:\n• Availability: Check if your workplace offers EV charging or consider advocating for its installation.\n• Benefits: Workplace charging can effectively double your electric range, making EVs viable for those with longer commutes.\n• Types: Most workplace chargers are Level 2, but some companies are installing DC fast chargers.\n• Cost: Some employers offer free charging as an employee benefit, while others may charge a fee.\n• Etiquette: Follow any workplace guidelines for charging, such as moving your vehicle once charged or sharing chargers.\n• Tax Implications: In some regions, free workplace charging may be considered a taxable benefit.\n• Scheduling: If chargers are limited, your workplace might implement a scheduling system to ensure fair access.\n• Incentives: Some governments offer incentives to businesses for installing workplace charging stations."),

        ("Charging Best Practices", "Follow these best practices to optimize your EV's battery life and charging efficiency:\n• Avoid frequent DC fast charging: While convenient, frequent use can degrade battery life faster. Use it primarily for long trips.\n• Keep the battery between 20% and 80% for daily use: This range is optimal for battery longevity.\n• Charge to 100% only for long trips: Regularly charging to 100% can stress the battery.\n• Avoid letting the battery drop to 0%: This can be harmful to the battery's health.\n• Use scheduled charging: If your utility offers time-of-use rates, schedule charging during off-peak hours to save money.\n• Precondition your battery: Many EVs allow you to warm up or cool down the battery while plugged in, which can improve efficiency and range.\n• Maintain a consistent charging routine: Regular, predictable charging is better for the battery than sporadic, extreme charging cycles.\n• Update your vehicle's software: Manufacturers often release updates that can improve battery management and charging efficiency.\n• Be mindful of temperature extremes: Very hot or cold temperatures can affect charging speed and efficiency. If possible, park in a temperature-controlled area."),

        ("Future of EV Charging", "The EV charging landscape is rapidly evolving:\n• Wireless Charging: Several companies are developing wireless charging pads for EVs, which could make charging as simple as parking your car.\n• Ultra-Fast Charging: New technologies aim to reduce charging times to as little as 10 minutes for a full charge.\n• Vehicle-to-Grid (V2G): This technology allows EVs to not only draw power from the grid but also supply it back, potentially earning money for owners and stabilizing the power grid.\n• Solar Integration: More charging stations are being integrated with solar panels, providing clean, renewable energy for charging.\n• Smart Charging: AI-driven charging systems that optimize charging based on grid demand, energy prices, and user preferences are becoming more common.\n• Battery Swapping: Some companies are exploring battery swapping as an alternative to traditional charging, allowing for near-instant 'refueling'.\n• Increased Charging Speed: Advancements in battery technology are allowing for higher charging speeds without compromising battery life.\n• Standardization: Efforts are underway to standardize charging connectors and payment systems globally, which could greatly simplify the charging experience.")
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



