//
//  DiskCache.swift
//  cache
//
//  Created by mramotar on 8/15/22.
//

import Foundation
import squirrel

open class DiskCache<T: Codable>: Cache {
    public typealias This = T
    public typealias That = ByteArray
    
    public var name: String
    var cacheUrl: URL
    
    public let fileManager = FileManager()
    public let dispatchQueue = DispatchQueue(label: "SQUIRREL", attributes: DispatchQueue.Attributes.concurrent)
    public let converter = ByteArrayConverter<This>()
    
    public init(name: String) {
        self.name = name
        
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheUrl = url.appendingPathComponent("SQUIRREL/\(name)")
        
        do {
            try fileManager.createDirectory(at: self.cacheUrl, withIntermediateDirectories: true)
        } catch { }
    }
    
    public func add(key: String, value: Any?, expiration_ expiration: KotlinLong?) {
        let codableEntry = CodableEntry<CodableClass<This>>(key: key, value: CodableClass(value as! This))
        let byteArray = self.converter.from(value: codableEntry)
        do {
            try NSKeyedArchiver.archivedData(withRootObject: byteArray, requiringSecureCoding: false)
        } catch {}
    }
    
    public func delete(key: String) -> Bool {
        let url = url(key).path
        do {
            try fileManager.removeItem(atPath: url)
            return true
        } catch {
            return false
        }
    }
    
    public func deleteAll() {
        for key in keys() {
            delete(key: key)
        }
    }
    
    public func get(key: String, serializer: KSerializer) -> Any? {
        if let entry = getEntry(key: key) {
            let codableClass = entry.value as! CodableClass<This>
            return codableClass.value
        }
        return nil
    }
    
    
    public func getCodableEntry(key: String) -> CodableEntry<This>? {
        let url = url(key).path
        if fileManager.fileExists(atPath: url) {
            do {
                if let codableEntry = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileManager.contents(atPath: url)!) {
                    return codableEntry as? CodableEntry<This>
                }
            } catch {}
        }
        return nil
    }
    
    public func getEntry(key: String) -> Entry_<AnyObject>? {
        if let codableEntry = getCodableEntry(key: key) {
            let codableClass = CodableClass(codableEntry.value)
            let entry = Entry_(key: codableEntry.key, value: codableClass as AnyObject, updated: codableEntry.updated, expiration: codableEntry.expiration)
            return entry
        }
        return nil
    }
    
    public func keys() -> Set<String> {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return Set(urls.compactMap { $0.absoluteString } )
    }
    
    public func url(_ key: String) -> URL {
        return self.cacheUrl
            .appendingPathComponent(key)
            .appendingPathExtension("SQUIRREL")
    }
    
}
