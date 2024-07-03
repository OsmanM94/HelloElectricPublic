//
//  NetworkMonitor.swift
//  Clin
//
//  Created by asia on 03/07/2024.
//

import Foundation
import Network

@Observable
final class NetworkMonitor {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected: Bool = false
    
    init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: workerQueue)
    }
}
