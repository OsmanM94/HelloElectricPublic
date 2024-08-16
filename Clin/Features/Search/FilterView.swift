//
//  FilterView.swift
//  Clin
//
//  Created by asia on 14/08/2024.
//

import SwiftUI

struct FilterView: View {
    @Binding var selectedMake: String
    @Binding var selectedModel: String
    @Binding var selectedYear: Int
    @Binding var maxPrice: Double
    
    var makes: [String]
    var models: [String]
    
    var applyFilters: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Make")) {
                    Picker("Select Make", selection: $selectedMake) {
                        ForEach(makes, id: \.self) { make in
                            Text(make).tag(make)
                        }
                    }
                }
                
                Section(header: Text("Model")) {
                    Picker("Select Model", selection: $selectedModel) {
                        ForEach(models, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
                
                Section(header: Text("Year")) {
                    Stepper("Year: \(selectedYear, format: .number.precision(.fractionLength(0)))", value: $selectedYear, in: 2000...2024)
                }
                
                Section(header: Text("Maximum Price")) {
                    Slider(value: $maxPrice, in: 0...100000, step: 1000) {
                        Text("Price")
                    }
                    Text("Selected Price: \(maxPrice, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))")
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        applyFilters()
                    } label: {
                        Text("Apply")
                    }

                }
            }
        }
    }
}

#Preview {
    FilterView(
        selectedMake: .constant("Tesla"),
        selectedModel: .constant("Model S"),
        selectedYear: .constant(2024),
        maxPrice: .constant(100000),
        makes: ["Tesla", "Ford", "Toyota"], // Example makes
        models: ["Model S", "Model 3", "Mustang", "Corolla"], // Example models
        applyFilters: {}
    )
}
