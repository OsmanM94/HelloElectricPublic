//
//  CompanyInfoView.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import SwiftUI

struct CompanyInfoView: View {
    @State private var companyInfo: [String: Any]?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var companyNumber: String = ""

    var body: some View {
        VStack {
            TextField("Enter Company Number", text: $companyNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isLoading {
                ProgressView()
            } else if let error = error {
                Text("Error: \(String(describing: error))") // More descriptive error
                    .foregroundColor(.red)
            } else if let info = companyInfo {
                Text("Company Name: \(info["company_name"] as? String ?? "N/A")")
                Text("Company Number: \(info["company_number"] as? String ?? "N/A")")
                Text("Company Status: \(info["company_status"] as? String ?? "N/A")")
                // Add more fields as needed
            }
            
            Button("Fetch Company Info") {
                Task {
                    await fetchInfo()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(companyNumber.isEmpty)
        }
        .padding()
    }
    
    func fetchInfo() async {
        isLoading = true
        error = nil
        do {
            let api = CompaniesHouseAPI()
            companyInfo = try await api.getBasicCompanyInformation(companyNumber: companyNumber)
        } catch {
            self.error = error
            print("Error fetching company info: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    CompanyInfoView()
}
