//
//  SupabaseManager.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    private init() {
        let supabaseUrl = URL(string: "https://qlermybdexasoxuvuppj.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsZXJteWJkZXhhc294dXZ1cHBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkxNTIxNzQsImV4cCI6MjAzNDcyODE3NH0.gcPMD8-obqU8KTmPNLWkwOk_GOm7vXPalCFKcAfb-wg"
        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
}





