//
//  DiskCache.swift
//  Prism
//
//  Created by MinwooJe on 3/12/26.
//

import Foundation
import os

actor DiskCache {
    private let directoryURL: URL
    private let ttl: TimeInterval

    static let shared = DiskCache()

    private static let encoder: JSONEncoder = .init()
    private static let decoder: JSONDecoder = .init()
    private let fileManager: FileManaging

    init(fileManager: FileManaging = FileManager.default) {
        self.fileManager = fileManager
        self.directoryURL = self.fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appending(path: "Prism", directoryHint: .isDirectory)
        self.ttl = 7 * 24 * 60 * 60

        do {
            try self.fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            let cacheError = PrismError.cacheError(reason: .createDirectoryFailed(url: directoryURL, error: error))
            PrismLogger.disk.error("\(cacheError)")
        }
    }

    func retrieve(forKey url: URL) -> Data? {
        let cacheKey = CacheKey(url: url)
        let filePath = getFilePath(forKey: cacheKey.value)

        // 메타데이터를 읽을 수 없어 최신성을 보장할 수 없다면 캐시 miss로 처리 및 해당 데이터 제거.
        guard let attributes = try? fileManager.attributesOfItem(atPath: filePath.path()),
              let createdAt = attributes[.creationDate] as? Date
        else {
            try? remove(forKey: url)
            return nil
        }

        if Date().timeIntervalSince(createdAt) > ttl {
            try? remove(forKey: url)
            return nil
        }

        guard let data = fileManager.contents(atPath: filePath.path()) else { return nil }

        do {
            let cacheEntry = try decode(CacheEntry.self, from: data)
            return cacheEntry.data
        } catch {
            try? remove(forKey: url)     // 손상된 파일 제거
            return nil
        }
    }

    func store(_ data: Data, forKey url: URL) throws(PrismError) {
        let cacheKey = CacheKey(url: url)
        let cacheEntry: CacheEntry = .init(data: data)

        let filePath = getFilePath(forKey: cacheKey.value)
        let encodedEntry = try encode(cacheEntry)

        let isSuccess = fileManager.createFile(atPath: filePath.path(), contents: encodedEntry, attributes: nil)

        guard isSuccess else {
            let cacheError = PrismError.cacheError(
                reason: .createCacheFileFailed(
                    path: url,
                    key: cacheKey.value,
                    data: data
                )
            )
            PrismLogger.disk.error("\(cacheError)")
            throw cacheError
        }
    }

    func remove(forKey url: URL) throws(PrismError) {
        let cacheKey = CacheKey(url: url)
        let filePath = getFilePath(forKey: cacheKey.value)

        do {
            try fileManager.removeItem(at: filePath)
        } catch {
            let cacheError = PrismError.cacheError(
                reason: .removeCacheFileFailed(
                    path: url,
                    key: cacheKey.value,
                    error: error
                )
            )
            PrismLogger.disk.error("\(cacheError)")
            throw cacheError
        }
    }
}

extension DiskCache {

    func getFilePath(forKey key: String) -> URL {
        directoryURL.appending(path: key, directoryHint: .notDirectory)
    }

}

extension DiskCache {

    func encode<T: Encodable>(_ value: T) throws(PrismError) -> Data {
        do {
            return try Self.encoder.encode(value)
        } catch {
            throw PrismError.processingError(reason: .processingFailed)
        }
    }

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws(PrismError) -> T {
        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch {
            throw PrismError.processingError(reason: .processingFailed)
        }
    }

}
