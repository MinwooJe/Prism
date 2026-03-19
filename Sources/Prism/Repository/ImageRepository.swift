//
//  ImageRepository.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import UIKit

fileprivate extension AsyncStream.Continuation {
    /// yield와 finish를 한번에 수행하는 헬퍼 메서드입니다.
    func yieldAndFinish(_ value: sending Element) {
        self.yield(value)
        self.finish()
    }
}

actor ImageRepository: Sendable {

    private var inFlightTaskMap = [URL: Task<UIImage, Error>]()

    private let imageDownloader: ImageDownloader
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache

    static let shared = ImageRepository()

    init(
        imageDownloader: ImageDownloader = ImageDownloader(),
        memoryCache: MemoryCache = MemoryCache.shared,
        diskCache: DiskCache = DiskCache.shared
    ) {
        self.imageDownloader = imageDownloader
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }

    /// ImageLoadState의 AsyncStream을 즉시 반환합니다.
    ///
    /// 에러는 Stream 내부 Task에서 발생하므로 throws function이 아닙니다.
    func imageStream(from url: URL?) -> AsyncStream<ImageLoadingState> {
        AsyncStream { continuation in
            continuation.yield(.loading)

            guard let url else {
                continuation.yield(.failed(.networkError(reason: .invalidURL)))
                continuation.finish()
                return
            }

            let task = Task {
                do {
                    let image = try await fetchImage(for: url)
                    continuation.yieldAndFinish(.success(image: image))
                } catch let error as PrismError {
                    continuation.yieldAndFinish(.failed(error))
                } catch {
                    continuation.yieldAndFinish(.failed(.unknown(error)))
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func fetchImage(for url: URL) async throws -> UIImage {
        if let inFlightTask = inFlightTaskMap[url] {
            return try await inFlightTask.value
        }

        let task = Task {
            if let image = await memoryCache.retrieve(forKey: url) {
                return image
            }

            if let cachedData = await diskCache.retrieve(forKey: url),
               let image = UIImage(data: cachedData) {
                await memoryCache.store(image, forKey: url)
                return image
            }

            let imageData = try await imageDownloader.fetchImage(from: url)

            guard let image = UIImage(data: imageData) else {
                throw PrismError.processingError(reason: .processingFailed)
            }

            await memoryCache.store(image, forKey: url)
            try? await diskCache.store(imageData, forKey: url)

            return image
        }
        inFlightTaskMap[url] = task
        defer { inFlightTaskMap.removeValue(forKey: url) }

        return try await task.value
    }

}
