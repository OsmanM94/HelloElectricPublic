//
//  MockDataDownloader.swift
//  Clin
//
//  Created by asia on 16/08/2024.
//

import Foundation

struct MockHTTPDataDownloader: HTTPDataDownloaderProtocol {
    func loadData<T>(as type: T.Type, endpoint: String,  headers: [String : String]?) async throws -> T where T : Decodable {
        return try JSONDecoder().decode(T.self, from: Data())
    }
    
    func postData<T, U>(as type: T.Type, to endpoint: String, body: U, headers: [String : String]) async throws -> T where T : Decodable, U : Encodable {
        return try JSONDecoder().decode(T.self, from: Data())
    }
    
    func fetchURL(from url: URL) async throws -> Data {
        return Data()
    }
    
    func fetchData(from url: URL) async throws -> Data {
        return Data() 
    }
}

