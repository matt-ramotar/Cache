//
//  CodableConverter.swift
//  cache
//
//  Created by mramotar on 8/15/22.
//

import Foundation

public protocol CodableConverter {
    associatedtype T: Codable
    associatedtype This: CodableClass<T>
    associatedtype That: Codable
    
    func from(value: CodableEntry<This>) -> That?
    func to(value: That) -> CodableEntry<This>?
}
