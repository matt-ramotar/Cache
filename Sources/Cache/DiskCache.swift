//
//  DiskCache.swift
//  cache
//
//  Created by mramotar on 8/15/22.
//

import Foundation
import squirrel

class DiskCache<T: Codable>: Cache {
    typealias This = T
    typealias That = ByteArray
    
    var name: String
    var cacheUrl: URL
    
    private let fileManager = FileManager()
    private let dispatchQueue = DispatchQueue(label: "SQUIRREL", attributes: DispatchQueue.Attributes.concurrent)
    private let converter = ByteArrayConverter<This>()
    
    init(name: String) {
        self.name = name
        
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheUrl = url.appendingPathComponent("SQUIRREL/\(name)")
        
        do {
            try fileManager.createDirectory(at: self.cacheUrl, withIntermediateDirectories: true)
        } catch { }
    }
    
    func add(key: String, value: Any?, expiration_ expiration: KotlinLong?) {
        let codableEntry = CodableEntry<CodableClass<This>>(key: key, value: CodableClass(value as! This))
        let byteArray = self.converter.from(value: codableEntry)
        do {
            try NSKeyedArchiver.archivedData(withRootObject: byteArray, requiringSecureCoding: false)
        } catch {}
    }
    
    func delete(key: String) -> Bool {
        let url = url(key).path
        do {
            try fileManager.removeItem(atPath: url)
            return true
        } catch {
            return false
        }
    }
    
    func deleteAll() {
        for key in keys() {
            delete(key: key)
        }
    }
    
    func get(key: String, serializer: KSerializer) -> Any? {
        if let entry = getEntry(key: key) {
            let codableClass = entry.value as! CodableClass<This>
            return codableClass.value
        }
        return nil
    }
    
    
    private func getCodableEntry(key: String) -> CodableEntry<This>? {
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
    
    func getEntry(key: String) -> Entry_<AnyObject>? {
        if let codableEntry = getCodableEntry(key: key) {
            let codableClass = CodableClass(codableEntry.value)
            let entry = Entry_(key: codableEntry.key, value: codableClass as AnyObject, updated: codableEntry.updated, expiration: codableEntry.expiration)
            return entry
        }
        return nil
    }
    
    func keys() -> Set<String> {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return Set(urls.compactMap { $0.absoluteString } )
    }
    
    private func url(_ key: String) -> URL {
        return self.cacheUrl
            .appendingPathComponent(key)
            .appendingPathExtension("SQUIRREL")
    }
    
}
