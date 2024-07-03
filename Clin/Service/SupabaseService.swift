//
//  SupabaseManager.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation
import Supabase

struct SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    private init() {
        let supabaseUrl = URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0Z2NzZHFocHFsc3J6anp1dGZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTk2OTU1NTYsImV4cCI6MjAzNTI3MTU1Nn0.QUjlLd0iYretplc_i8SIbMo8jbo0d1yRVe4O1OOZnYo"
        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
}





