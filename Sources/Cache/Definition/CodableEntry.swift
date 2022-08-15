//
//  CodableEntry.swift
//  cache
//
//  Created by mramotar on 8/15/22.
//

import Foundation

public class CodableEntry<T: Codable>: Codable {
    let key: String
    let value: T
    let expiration: Int64
    let updated: Int64
    
    init(key: String, value: T, expiration: Int64 = Int64.max, updated: Int64 = Int64(NSDate().timeIntervalSince1970)) {
        self.key = key
        self.value = value
        self.expiration = expiration
        self.updated = updated
    }
}
