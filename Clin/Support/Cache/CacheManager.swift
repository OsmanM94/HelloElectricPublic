//
//  CacheManager.swift
//  Clin
//
//  Created by asia on 30/08/2024.
//

import Foundation


//class CacheManager<T: Codable> {
//    
//    private let cache = NSCache<NSString, NSData>()
//    
//    init() {}
//    
//    func set(_ items: [T], forKey key: String) {
//        do {
//            let data = try JSONEncoder().encode(items)
//            cache.setObject(data as NSData, forKey: key as NSString)
//            print("DEBUG: Cached data for key \(key)")
//        } catch {
//            print("DEBUG: Failed to encode items for key \(key): \(error)")
//        }
//    }
//    
//    func get(forKey key: String) -> [T]? {
//        if let data = cache.object(forKey: key as NSString) as Data? {
//            do {
//                let decodedItems = try JSONDecoder().decode([T].self, from: data)
//                print("DEBUG: Retrieved cached data for key \(key)")
//                return decodedItems
//            } catch {
//                print("DEBUG: Failed to decode data for key \(key): \(error)")
//                return nil
//            }
//        } else {
//            print("DEBUG: No data found in cache for key \(key)")
//            return nil
//        }
//    }
//}

//final class Cache<Key: Hashable, Value> {
//    private let wrapped = NSCache<WrappedKey, Entry>()
//
//    func insert(_ value: Value, forKey key: Key) {
//        let entry = Entry(value: value)
//        wrapped.setObject(entry, forKey: WrappedKey(key))
//    }
//
//    func value(forKey key: Key) -> Value? {
//        let entry = wrapped.object(forKey: WrappedKey(key))
//        return entry?.value
//    }
//
//    func removeValue(forKey key: Key) {
//        wrapped.removeObject(forKey: WrappedKey(key))
//    }
//}
//
//
//private extension Cache {
//    final class WrappedKey: NSObject {
//        let key: Key
//
//        init(_ key: Key) { self.key = key }
//
//        override var hash: Int { return key.hashValue }
//
//        override func isEqual(_ object: Any?) -> Bool {
//            guard let value = object as? WrappedKey else {
//                return false
//            }
//
//            return value.key == key
//        }
//    }
//}
//
//private extension Cache {
//    final class Entry {
//        let value: Value
//
//        init(value: Value) {
//            self.value = value
//        }
//    }
//}
//
// extension Cache {
//    subscript(key: Key) -> Value? {
//        get { return value(forKey: key) }
//        set {
//            guard let value = newValue else {
//                // If nil was assigned using our subscript,
//                // then we remove any value for that key:
//                removeValue(forKey: key)
//                return
//            }
//            
//            insert(value, forKey: key)
//        }
//    }
//}
//

class GenericCache<T: Codable> {
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
}

// CacheManager to handle different cache types
class CacheManager {
    static let shared = CacheManager()
    
    private init() {}
    
    private var caches: [String: Any] = [:]
    
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
}


