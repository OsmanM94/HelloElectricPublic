//
//  EducationView.swift
//  Clin
//
//  Created by Osman on 28/08/2024.
//

import SwiftUI
import Charts

struct FuelRegistration: Identifiable {
    var id: Int
    let fuelType: String
    let count: Double
}

func colorForFuelType(_ fuelType: String) -> Color {
    switch fuelType {
    case "Electric": return .green
    case "Diesel": return .gray
    case "Petrol": return .blue
    default: return .black
    }
}

struct CombinedChartView: View {
    @State private var selectedChart: Int = 0
   
    let yearlyData: [FuelRegistration] = [
        FuelRegistration(id: 2001, fuelType: "Electric", count: 194.431),
        FuelRegistration(id: 2002, fuelType: "Diesel", count: 74.928),
        FuelRegistration(id: 2003, fuelType: "Petrol", count: 630.966)
    ]
    
    let monthlyData: [FuelRegistration] = [
        FuelRegistration(id: 1994, fuelType: "Electric", count: 27.335),
        FuelRegistration(id: 1995, fuelType: "Diesel", count: 8.708),
        FuelRegistration(id: 1996, fuelType: "Petrol", count: 76.879)
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Picker("Chart Type", selection: $selectedChart) {
                    Text("Month").tag(0)
                    Text("Year").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ZStack {
                    if selectedChart == 0 {
                        MonthlyChartView(registrations: monthlyData)
                    } else {
                        YearlyChartView(registrations: yearlyData)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedChart)
                
                
            }
        }
    }
}

struct YearlyChartView: View {
    let registrations: [FuelRegistration]
    
    var body: some View {
        VStack {
            Chart(registrations) { registration in
                BarMark(
                    x: .value("Fuel Type", registration.fuelType),
                    y: .value("Count", registration.count)
                )
                .foregroundStyle(by: .value("Fuel Type", registration.fuelType))
            }
            .chartForegroundStyleScale([
                "Electric": .green,
                "Diesel": .gray,
                "Petrol": .blue
            ])
            .frame(height: 300)
            .padding()
            
            // Legend
            VStack(alignment: .leading) {
                ForEach(registrations, id: \.id) { registration in
                    HStack {
                        Circle()
                            .fill(colorForFuelType(registration.fuelType))
                            .frame(width: 10, height: 10)
                        Text(registration.fuelType)
                        Spacer()
                        Text(registration.count, format: .number)
                    }
                }
            }
            .padding()
            
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Source: SMMT")
                        .font(.headline)
                    Text("Data for year to date 2024")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
        }
    }
}

struct MonthlyChartView: View {
    let registrations: [FuelRegistration]
    
    var body: some View {
        VStack(alignment: .leading) {
            Chart(registrations) { registration in
                SectorMark(
                    angle: .value("Count", registration.count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Fuel Type", registration.fuelType))
            }
            .chartForegroundStyleScale([
                "Electric": .green,
                "Diesel": .gray,
                "Petrol": .blue
            ])
            .frame(height: 300)
            .padding()
            
            // Legend
            VStack(alignment: .leading) {
                ForEach(registrations, id: \.id) { registration in
                    HStack {
                        Circle()
                            .fill(colorForFuelType(registration.fuelType))
                            .frame(width: 10, height: 10)
                        Text(registration.fuelType)
                        Spacer()
                        Text(registration.count, format: .number)
                    }
                }
            }
            .padding()
            
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Source: SMMT")
                        .font(.headline)
                    Text("Data for July 2024")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
        }
    }
}

#Preview {
    NavigationStack {
        CombinedChartView()
            .navigationTitle("Registrations")
    }
}
