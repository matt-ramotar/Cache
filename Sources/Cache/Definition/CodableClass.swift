//
//  CodableClass.swift
//  cache
//
//  Created by mramotar on 8/15/22.
//

import Foundation

public class CodableClass<T: Codable>: Codable {
    let value: T
    init(_ value: T) {
        self.value = value
    }
}
