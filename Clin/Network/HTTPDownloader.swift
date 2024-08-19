//
//  HTTPDownloader.swift
//  Clin
//
//  Created by asia on 16/08/2024.
//

import Foundation

class HTTPDataDownloader: HTTPDataDownloaderProtocol {
    
    func fetchData <T: Decodable>(as type: T.Type, endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw HTTPError.requestFailed(description: "Invalid URL")
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.requestFailed(description: "Request failed")
        }
        guard httpResponse.statusCode == 200 else {
            throw HTTPError.invalidStatusCode(statuscode: httpResponse.statusCode)
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw error as? HTTPError ?? .decodingError(error: error)
        }
    }
    
    func postData<T: Decodable, U: Encodable>(as type: T.Type, to endpoint: String, body: U, headers: [String: String] = [:]) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw HTTPError.requestFailed(description: "Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            throw HTTPError.encodingError(error: error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.requestFailed(description: "Request failed")
        }
        guard httpResponse.statusCode == 200 else {
            throw HTTPError.invalidStatusCode(statuscode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw error as? HTTPError ?? .decodingError(error: error)
        }
    }
    
    func fetchURL(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}


