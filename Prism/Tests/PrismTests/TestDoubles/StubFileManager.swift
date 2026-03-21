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
        let creationDate = fileStorage[path]?.creationDate
        return [.creationDate: creationDate as Any]
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
            fileStorage[path] = .init(data: data, creationDate: Date())
            return true
        }
        return false
    }

    func removeItem(at url: URL) throws {
        fileStorage.removeValue(forKey: url.path())
    }

}
