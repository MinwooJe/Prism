//
//  StubFileManager.swift
//  Prism
//
//  Created by MinwooJe on 3/20/26.
//

import Foundation
@testable import Prism

final class StubFileManager: FileManaging {
    struct DataEntry {
        let data: Data
        let creationDate: Date
        var modificationDate: Date
    }

    private(set) var fileStorage = [String: DataEntry]()

    private let cacheDirectoryURL: URL

    init(cacheDirectoryURL: URL = URL(fileURLWithPath: "/tests/caches/Prism")) {
        self.cacheDirectoryURL = cacheDirectoryURL
    }

    func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL] {
        [cacheDirectoryURL.deletingLastPathComponent()]
    }

    func contents(atPath path: String) -> Data? {
        fileStorage[path]?.data
    }

    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any] {
        guard let entry = fileStorage[path] else {
            throw NSError(domain: "StubFileManager", code: 1)
        }
        return [
            .creationDate: entry.creationDate,
            .modificationDate: entry.modificationDate,
            .size: entry.data.count
        ]
    }

    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey : Any]?
    ) throws {
        if fileStorage[url.path()] != nil {
            fileStorage[url.path()] = nil
        }
    }

    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        if let data {
            let now = Date()
            fileStorage[path] = .init(data: data, creationDate: now, modificationDate: now)
            return true
        }
        return false
    }

    func removeItem(at url: URL) throws {
        fileStorage.removeValue(forKey: url.path())
    }

    func setAttributes(
        _ attributes: [FileAttributeKey: Any],
        ofItemAtPath path: String
    ) throws {
        guard var entry = fileStorage[path] else {
            throw NSError(domain: "StubFileManager", code: 1)
        }
        if let modDate = attributes[.modificationDate] as? Date {
            entry.modificationDate = modDate
        }
        fileStorage[path] = entry
    }

    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL] {
        let dirPath = url.path()
        return fileStorage.keys
            .filter { $0.hasPrefix(dirPath) && $0 != dirPath }
            .map { URL(filePath: $0) }
    }

}
