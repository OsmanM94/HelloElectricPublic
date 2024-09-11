//
//  EducationView.swift
//  Clin
//
//  Created by Osman on 28/08/2024.
//

import SwiftUI
import Charts

fileprivate func colorForFuelType(_ fuelType: String) -> Color {
    switch fuelType {
    case "Electric": return .green
    case "Diesel": return .gray
    case "Petrol": return .blue
    default: return .black
    }
}

struct ChartView: View {
    @State private var viewModel = ChartViewModel()
    @State private var selectedChart: Int = 0
   
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .loading:
                CustomProgressView()
                
            case .loaded:
                loadedView
                
            case .error(let message):
                ErrorView(message: message, retryAction: {})
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .task {
            if viewModel.monthlyData.isEmpty && viewModel.yearlyData.isEmpty {
               try? await viewModel.loadChartData()
            }
        }
    }
}

private extension ChartView {
    var loadedView: some View {
        VStack {
            Picker("Chart Type", selection: $selectedChart) {
                Text("Month").tag(0)
                Text("Year").tag(1)
            }
            .pickerStyle(.segmented)
            .padding([.bottom, .horizontal])
            
            ZStack {
                if selectedChart == 0 {
                    MonthlyChartView(viewModel: viewModel, registrations: viewModel.monthlyData)
                } else {
                    YearlyChartView(viewModel: viewModel, registrations: viewModel.yearlyData)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: selectedChart)
        }
    }
}

fileprivate struct YearlyChartView: View {
    var viewModel: ChartViewModel
    let registrations: [Registrations]
    
    var body: some View {
        ScrollView {
            VStack {
                Chart(registrations) { registration in
                    BarMark(
                        x: .value("Fuel Type", registration.fuelCategory),
                        y: .value("Count", registration.registrationCount)
                    )
                    .foregroundStyle(by: .value("Fuel Type", registration.fuelCategory))
                }
                .chartForegroundStyleScale([
                    "Electric": .green,
                    "Diesel": .gray,
                    "Petrol": .blue
                ])
                .frame(height: 300)
                .padding()
                .background(Color(.systemGray6), in: .rect(cornerRadius: 10))
                .padding()
                
                legendSection
                
                sourceSection
                
                explanationSection
                
                ChartDisclaimer()
            }
        }
    }
    
    private var legendSection: some View {
        VStack(alignment: .leading) {
            ForEach(registrations, id: \.id) { registration in
                HStack {
                    Circle()
                        .fill(colorForFuelType(registration.fuelCategory))
                        .frame(width: 10, height: 10)
                    Text(registration.fuelCategory)
                    Spacer()
                    Text(registration.registrationCount, format: .number)
                }
                .fontDesign(.rounded).bold()
            }
        }
        .padding()
    }
    
    private var sourceSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("Source: SMMT")
                    .font(.headline)
                Text(viewModel.selectedYear)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Yearly Vehicle Registrations")
                .font(.headline)
            Text("This chart shows the distribution of vehicle registrations by fuel type for the current year. It provides a comprehensive view of the market share for electric, diesel, and petrol vehicles over the entire year.")
                .font(.subheadline)
        }
        .padding()
    }
}

fileprivate struct MonthlyChartView: View {
    var viewModel: ChartViewModel
    let registrations: [Registrations]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Chart(registrations) { registration in
                    SectorMark(
                        angle: .value("Count", registration.registrationCount),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Fuel Type", registration.fuelCategory))
                }
                .chartForegroundStyleScale([
                    "Electric": .green,
                    "Diesel": .gray,
                    "Petrol": .blue
                ])
                .frame(height: 300)
                .padding()
                .background(Color(.systemGray6), in: .rect(cornerRadius: 10))
                .padding()
                
                legendSection
               
                sourceSection
                
                explanationSection
                
                ChartDisclaimer()
            }
        }
    }
    
    private var legendSection: some View {
        VStack(alignment: .leading) {
            ForEach(registrations, id: \.id) { registration in
                HStack {
                    Circle()
                        .fill(colorForFuelType(registration.fuelCategory))
                        .frame(width: 10, height: 10)
                    Text(registration.fuelCategory)
                    Spacer()
                    Text(registration.registrationCount, format: .number)
                }
                .fontDesign(.rounded).bold()
            }
        }
        .padding()
    }
    
    private var sourceSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("Source: SMMT")
                    .font(.headline)
                Text(viewModel.selectedMonth)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Vehicle Registrations")
                .font(.headline)
            Text("This pie chart illustrates the proportion of vehicle registrations by fuel type for the above month. It provides a snapshot of the market share for electric, diesel, and petrol vehicles in this specific month.")
                .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ChartView()
            .navigationTitle("Registrations")
    }
}
