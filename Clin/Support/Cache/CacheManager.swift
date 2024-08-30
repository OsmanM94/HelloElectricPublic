//
//  CacheManager.swift
//  Clin
//
//  Created by asia on 30/08/2024.
//

import Foundation

protocol CacheClearing {
    func clear()
}

class GenericCache<T: Codable>: CacheClearing {
    private let cache = NSCache<NSString, NSData>()
    
    init() {}
    
    func set(_ data: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(data) else {
            return
        }
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func get(forKey key: String) -> T? {
        guard let data = cache.object(forKey: key as NSString) as Data? else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

// CacheManager to handle different cache types
class CacheManager {
    static let shared = CacheManager()
    
    private init() {}
    
    private var caches: [String: CacheClearing] = [:]
    
    func cache<T: Codable>(for type: T.Type) -> GenericCache<T> {
        let typeName = String(describing: type)
        if let existingCache = caches[typeName] as? GenericCache<T> {
            return existingCache
        } else {
            let newCache = GenericCache<T>()
            caches[typeName] = newCache
            return newCache
        }
    }
    
    func clearCache<T: Codable>(for type: T.Type) {
        let typeName = String(describing: type)
        if let existingCache = caches[typeName] as? GenericCache<T> {
            existingCache.clear()
        }
        caches.removeValue(forKey: typeName)
    }
    
    func clearAllCaches() {
        for (_, cache) in caches {
            cache.clear()
        }
        caches.removeAll()
    }
}


