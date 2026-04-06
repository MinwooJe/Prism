//
//  DiskCacheTests.swift
//  Prism
//
//  Created by MinwooJe on 4/6/26.
//

import Testing
import UIKit
@testable import Prism

struct DiskCacheTests {

    // MARK: - LRU Eviction Tests

    @Test
    func store_maxCount초과시_LRU항목제거() async throws {
        let sut = DiskCache(fileManager: StubFileManager(), maxDiskSize: .max, maxCount: 3)
        let urls = (0..<4).map { TestHelpers.makeURL(path: "image\($0).png") }
        let data = TestHelpers.makeTestImageData()

        for url in urls {
            try await sut.store(data, forKey: url)
        }

        let firstResult = await sut.retrieve(forKey: urls[0])
        #expect(firstResult == nil)

        for url in urls[1...] {
            let result = await sut.retrieve(forKey: url)
            #expect(result != nil)
        }
    }

    @Test
    func store_maxDiskSize초과시_LRU항목제거() async throws {
        let sut = DiskCache(fileManager: StubFileManager(), maxDiskSize: 300, maxCount: .max)
        let urls = (0..<5).map { TestHelpers.makeURL(path: "large\($0).png") }
        let data = TestHelpers.makeTestImageData()

        for url in urls {
            try await sut.store(data, forKey: url)
        }

        var remainingCount = 0
        for url in urls {
            if await sut.retrieve(forKey: url) != nil {
                remainingCount += 1
            }
        }
        #expect(remainingCount < urls.count)
    }

    @Test
    func retrieve_성공시_modificationDate갱신되어_eviction에서_살아남음() async throws {
        let sut = DiskCache(fileManager: StubFileManager(), maxDiskSize: .max, maxCount: 3)
        let urls = (0..<3).map { TestHelpers.makeURL(path: "item\($0).png") }
        let data = TestHelpers.makeTestImageData()

        for url in urls {
            try await sut.store(data, forKey: url)
        }

        let _ = await sut.retrieve(forKey: urls[0])

        let newURL = TestHelpers.makeURL(path: "item3.png")
        try await sut.store(data, forKey: newURL)

        let firstResult = await sut.retrieve(forKey: urls[0])
        #expect(firstResult != nil)

        let secondResult = await sut.retrieve(forKey: urls[1])
        #expect(secondResult == nil)
    }

    @Test
    func store_제한이내일경우_제거없음() async throws {
        let sut = DiskCache(fileManager: StubFileManager(), maxDiskSize: .max, maxCount: 3)
        let urls = (0..<3).map { TestHelpers.makeURL(path: "keep\($0).png") }
        let data = TestHelpers.makeTestImageData()

        for url in urls {
            try await sut.store(data, forKey: url)
        }

        for url in urls {
            let result = await sut.retrieve(forKey: url)
            #expect(result != nil)
        }
    }

    // MARK: - removeAll Tests

    @Test
    func removeAll_호출후_모든항목이_nil반환() async throws {
        let sut = DiskCache(fileManager: StubFileManager(), maxDiskSize: .max, maxCount: .max)
        let urls = (0..<3).map { TestHelpers.makeURL(path: "remove\($0).png") }
        let data = TestHelpers.makeTestImageData()

        for url in urls {
            try await sut.store(data, forKey: url)
        }

        try await sut.removeAll()

        for url in urls {
            let result = await sut.retrieve(forKey: url)
            #expect(result == nil)
        }
    }

}
