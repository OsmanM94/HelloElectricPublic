//
//  AboutUsView.swift
//  Clin
//
//  Created by asia on 17/09/2024.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                missionSection
                sustainabilitySection
                educationSection
                personalTouchSection
                futureVisionSection
            }
            .fontDesign(.rounded)
            .padding()
        }
        .navigationTitle("About Us")
    }
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text("HelloElectric")
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
    }
    
    private var missionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Our Mission")
                .font(.headline)
            
            Text("At HelloElectric, we're on a mission to accelerate the world's transition to sustainable transportation. We believe that by connecting EV enthusiasts, buyers, and sellers, we can make electric vehicles more accessible and desirable for everyone.")
        }
    }
    
    private var sustainabilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Promoting Sustainability")
                .font(.headline)
            
            Text("Our platform is more than just a marketplace – it's a community dedicated to promoting green energy and sustainable living. By choosing an electric vehicle, you're not just buying a car; you're investing in a cleaner, greener future for our planet.")
        }
    }
    
    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Educating About EVs")
                .font(.headline)
            
            Text("We're committed to educating people about the benefits and practicalities of electric vehicles. Through our platform, we provide resources, articles, and community discussions to help demystify EVs and empower people to make informed decisions.")
        }
    }
    
    private var personalTouchSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("A Labor of Love")
                .font(.headline)
            
            Text("HelloElectric was created by a single passionate individual who believes in the power of electric vehicles to change the world. Countless hours and resources have gone into building this platform, driven by the vision of a more sustainable future.")
            
            Text("Every feature, every line of code, and every user interaction has been carefully crafted to provide you with the best possible experience.")
        }
    }
    
    private var futureVisionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Looking to the Future")
                .font(.headline)
            
            Text("As we grow, we remain committed to our core values of sustainability, education, and community. We're constantly working on new features and improvements to make EV Marketplace even better for our users.")
            
            Text("Thank you for being part of our journey towards a cleaner, greener future!")
        }
    }
}


#Preview {
    NavigationStack {
        AboutUsView()
    }
}
