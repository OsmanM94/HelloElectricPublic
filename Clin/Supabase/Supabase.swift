//
//  SupabaseManager.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation
import Supabase

protocol SupabaseProtocol {
    var client: SupabaseClient { get }
}

final class SupabaseService: SupabaseProtocol {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
}

extension SupabaseService {
    static func createDefault() -> SupabaseService {
        let supabaseUrl = URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co")!
        let mama = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0Z2NzZHFocHFsc3J6anp1dGZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTk2OTU1NTYsImV4cCI6MjAzNTI3MTU1Nn0.QUjlLd0iYretplc_i8SIbMo8jbo0d1yRVe4O1OOZnYo"
        let client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: mama)
        return SupabaseService(client: client)
    }
}

final class MockSupabaseService: SupabaseProtocol {
    var client: SupabaseClient {
        return SupabaseClient(supabaseURL: URL(string: "https://mock.supabase.co")!,
                              supabaseKey: "mock_supabase_key")
    }
}




