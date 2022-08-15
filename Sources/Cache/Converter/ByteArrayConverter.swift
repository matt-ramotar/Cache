//
//  ByteArrayConverter.swift
//  cache
//
//  Created by mramotar on 8/15/22.
//

import Foundation

class ByteArrayConverter<T: Codable>: CodableConverter {
    typealias T = T
    typealias This = CodableClass<T>
    typealias That = ByteArray
    
    public func to(value: ByteArray) ->  CodableEntry<CodableClass<T>>? {
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            return try JSONDecoder().decode(CodableEntry<This>.self, from: data)
        } catch {
            return nil
        }
    }
    
    public func from(value: CodableEntry<This>) -> ByteArray? {
        do {
            let data = try JSONEncoder().encode(value)
            return Array(String(decoding: data, as: UTF8.self).utf8)
        } catch {
            return nil
        }
    }
    
    
}
