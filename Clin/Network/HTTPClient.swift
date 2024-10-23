import Foundation

class HTTPClient: httpClientProtocol {
    
    func loadData<T: Decodable>(
            as type: T.Type,
            endpoint: String,
            headers: [String: String]? = nil
        ) async throws -> T {
            
            guard let url = URL(string: endpoint) else {
                throw MessageCenter.MessageType.requestFailed(description: "Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add headers to the request if provided
            headers?.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MessageCenter.MessageType.requestFailed(description: "Request failed")
            }
            
            guard httpResponse.statusCode == 200 else {
                throw MessageCenter.MessageType.invalidStatusCode(statuscode: httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                throw MessageCenter.MessageType.decodingError(error: error)
            }
        }
    
    func postData<T: Decodable, U: Encodable>(as type: T.Type, to endpoint: String, body: U, headers: [String: String] = [:]) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw MessageCenter.MessageType.requestFailed(description: "Invalid URL")
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
            throw MessageCenter.MessageType.encodingError(error: error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MessageCenter.MessageType.requestFailed(description: "Request failed")
        }
        guard httpResponse.statusCode == 200 else {
            throw MessageCenter.MessageType.invalidStatusCode(statuscode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw MessageCenter.MessageType.decodingError(error: error)
        }
    }
    
    func loadURL(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}


