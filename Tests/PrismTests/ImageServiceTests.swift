//
//  ImageServiceTests.swift
//  Prism
//
//  Created by MinwooJe on 3/20/26.
//

import Testing
import UIKit
@testable import Prism

struct ImageServiceTests {

    private let spyDownloader: SpyImageDownloader
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache
    private let sut: ImageService

    init() {
        spyDownloader = SpyImageDownloader()
        memoryCache = MemoryCache()
        diskCache = DiskCache(fileManager: StubFileManager())

        self.sut = .init(
            imageDownloader: spyDownloader,
            memoryCache: memoryCache,
            diskCache: diskCache
        )
    }
}

// MARK: - Helpers

extension ImageServiceTests {

    private func makeURL(path: String = "test.png") -> URL {
        URL(string: "https://example.com/\(path)")!
    }

    private func makeTestImageData(with color: UIColor = .blue) -> Data {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()!
    }

    private func makeTestImage(with color: UIColor = .blue) -> UIImage {
        return UIImage(data: makeTestImageData(with: color))!
    }

}

// MARK: - Tests

extension ImageServiceTests {

    @Test
    func fetchImage_메모리캐시히트시_네트워크요청없이반환() async throws {
        let testURL = makeURL()
        let testImage = makeTestImage()
        await memoryCache.store(testImage, forKey: testURL)

        let _ = try await sut.fetchImage(for: testURL)

        #expect(spyDownloader.fetchCallCount == 0)
    }

    @Test
    func fetchImage_디스크캐시히트시_네트워크요청없이반환() async throws {
        let testURL = makeURL()
        let testImageData = makeTestImageData()
        try await diskCache.store(testImageData, forKey: testURL)

        let _ = try await sut.fetchImage(for: testURL)

        #expect(spyDownloader.fetchCallCount == 0)
    }

    @Test
    func fetchImage_캐시가비어있으면_네트워크에서가져오고_캐시저장() async throws {
        let testURL = makeURL()
        spyDownloader.stubbedImageData =  makeTestImageData()
        try #require(await memoryCache.retrieve(forKey: testURL) == nil)
        try #require(await diskCache.retrieve(forKey: testURL) == nil)

        _ = try await sut.fetchImage(for: testURL)

        #expect(await memoryCache.retrieve(forKey: testURL) != nil)
        #expect(await diskCache.retrieve(forKey: testURL) != nil)
        #expect(spyDownloader.fetchCallCount == 1)
    }

    @Test
    func fetchImage_메모리캐시미스_디스크캐시히트시_메모리캐시갱신() async throws {
        let testURL = makeURL()
        let testImageData = makeTestImageData()
        try await diskCache.store(testImageData, forKey: testURL)
        try #require(await memoryCache.retrieve(forKey: testURL) == nil)
        try #require(await diskCache.retrieve(forKey: testURL) != nil)

        _ = try await sut.fetchImage(for: testURL)

        #expect(await memoryCache.retrieve(forKey: testURL) != nil)
    }

    @Test
    func fetchImage_동일한URL동시요청시_하나의요청만발생() async throws {
        let testURL = makeURL()
        spyDownloader.stubbedImageData = makeTestImageData()

        async let image1 = sut.fetchImage(for: testURL)
        async let image2 = sut.fetchImage(for: testURL)
        async let image3 = sut.fetchImage(for: testURL)
        _ = try await [image1, image2, image3]

        #expect(spyDownloader.fetchCallCount == 1)
    }

}
