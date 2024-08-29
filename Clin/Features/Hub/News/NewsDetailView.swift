//
//  NewsDetailView.swift
//  Clin
//
//  Created by asia on 28/08/2024.
//

import SwiftUI

struct NewsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let article: NewsArticle
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                if let url = URL.from(article.urlToImage) {
                    ImageLoader(url: url, contentMode: .fill,
                                targetSize: CGSize(width: 350, height: 350))
                    .clipped()
                    .frame(maxWidth: .infinity, minHeight: 350)
                } else {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.5))
                        .overlay {
                            Text("No Images Available")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                }
             
                Button(action: {
                   dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .foregroundStyle(.white)
                        .padding()
                        .padding(.top, 20)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(article.source.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(article.publishedAt.toFormattedDateString())
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                
                    Text(article.content)
                        .font(.body)
                        .lineSpacing(8)
                    
                    Link("Read full article", destination: URL(string: article.url)!)
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .padding(.top)
                }
                .padding()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NewsDetailView(article: NewsArticle(
        source: Source(id: "bbc-news", name: "BBC News"),
        title: "Tesla Unveils Revolutionary Model 5: A Game-Changer in Electric Vehicles",
        description: "Elon Musk's Tesla has shocked the automotive world with the surprise announcement of its latest electric vehicle, the Model 5, boasting unprecedented range and innovative features.",
        url: "https://www.bbc.com/news/technology/tesla-model-5-announcement",
        publishedAt: "2024-08-28T09:30:00Z",
        content: """
        In a surprise move that has sent shockwaves through the automotive industry, Tesla CEO Elon Musk unveiled the company's latest electric vehicle, the Model 5, during a live-streamed event from Tesla's Gigafactory in Austin, Texas.

        The Model 5, slated for production in early 2025, promises to revolutionize the electric vehicle market with its groundbreaking features:

        1. Range: An industry-leading 600 miles on a single charge, addressing one of the primary concerns of potential EV adopters.
        2. Charging Speed: Capable of adding 300 miles of range in just 15 minutes when using Tesla's next-generation Superchargers.
        3. Autonomous Driving: Equipped with Tesla's most advanced self-driving hardware and software, aiming for full autonomy pending regulatory approval.
        4. Sustainability: Built using 80% recycled materials and powered by a new generation of cobalt-free batteries.
        5. Performance: 0-60 mph in under 2 seconds, making it one of the fastest production cars in the world.

        "The Model 5 represents the culmination of everything we've learned about electric vehicles and sustainable energy," Musk stated during the presentation. "It's not just a car; it's a glimpse into the future of transportation."

        Industry analysts are already speculating about the impact of the Model 5 on both the electric vehicle market and traditional automakers. "This could be the tipping point for mass EV adoption," said Sarah Johnson, a senior analyst at AutoTech Insights. "Traditional car manufacturers will need to accelerate their EV programs significantly to keep up."

        The announcement has also had an immediate impact on Tesla's stock, with shares surging over 15% in after-hours trading. However, some skeptics question Tesla's ability to deliver on its ambitious promises, pointing to past issues with production delays and quality control.

        The Model 5 is expected to start at $45,000 for the base model, with reservations opening next month. Tesla aims to begin deliveries in the United States by Q2 2025, with international markets following later that year.

        As the automotive world digests this news, one thing is clear: the race towards an all-electric future has just shifted into high gear.
        """,
        urlToImage: "https://media.wired.com/photos/66a56f21bf2909f08a634953/191:100/w_1280,c_limit/Crypto-Bros-Business-2162975355.jpg"
    ))
}
