//
//  DataPacketCache.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/4/23.
//

import Foundation

class DataCache<K, V> where K : Hashable {
    private var dataCache: Dictionary<K, V> = Dictionary()
    private var dataRetryCount: Dictionary<K, Int> = Dictionary()
    
    func removeValueFromCache(key: K) {
        dataCache.removeValue(forKey: key)
        dataRetryCount.removeValue(forKey: key)
    }
    
    func addValueToCache(key: K, value: V) {
        dataCache.updateValue(value, forKey: key)
        dataRetryCount.updateValue(0, forKey: key)
    }
    
    func getCache(key: K) -> V? {
        if let cache = dataCache[key] {
            return cache
        }
        
        return nil
    }
    
    func getRetryCounter(key: K) -> Int? {
        if let counter = dataRetryCount[key] {
            return counter
        }
        
        return nil
    }
    
    func updateRetryCounter(key: K, counter: Int) {
        dataRetryCount.updateValue(counter, forKey: key)
    }
}
