//
//  UploadListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI

struct UploadListingView: View {
    var body: some View {
        NavigationStack {
            Group {
                Form {
                    Section("Registration Number") {
                        
                    }
                    Button(action: {
                         
                    }) {
                        Text("Registration checker here")
                    }
                    
//                    if let errorMessage = errorMessage {
                    //                        Text(errorMessage)
                    //                            .foregroundStyle(.red)
                    //                    }
                    Section("Images") {
                        HStack {
                            
                        }
                        .frame(height: 200)
                    }
                    
                    Section("Title") {
                        
                    }
                    Section("Mileage") {
                        
                    }
                    Section("Make") {
                        
                    }
                    Section("Model") {
                        
                    }
                    Section("Year") {
                        
                    }
                    Section("Colour") {
                       
                    }
                    Section("Price") {
                        
                    }
                }
                .navigationTitle("Selling")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    UploadListingView()
}
