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

final class ImageRepository: Sendable {

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
    func fetchImage(from url: URL?) -> AsyncStream<ImageLoadingState> {
        AsyncStream { continuation in
            Task {
                continuation.yield(.loading)

                guard let url else {
                    continuation.yield(.failed(.networkError(reason: .invalidURL)))
                    continuation.finish()
                    return
                }

                if let image = await cachedImage(for: url) {
                    continuation.yieldAndFinish(.success(image: image))
                    return
                }

                do {
                    let imageData = try await imageDownloader.fetchImage(from: url)

                    guard let image = UIImage(data: imageData) else {
                        throw PrismError.processingError(reason: .processingFailed)
                    }

                    continuation.yieldAndFinish(.success(image: image))

                    await memoryCache.store(image, forKey: url)

                    // 캐시 저장 실패는 치명적인 오류가 아니므로 에러를 전파하지 않고 로깅(DiskCache 내부)만 진행
                    try? await diskCache.store(imageData, forKey: url)

                } catch let error as PrismError {
                    continuation.yieldAndFinish(.failed(error))
                } catch {
                    continuation.yieldAndFinish(.failed(.unknown(error)))
                }
            }
        }
    }

}

extension ImageRepository {
    private func cachedImage(for url: URL) async -> UIImage? {
        if let image = await memoryCache.retrieve(forKey: url) {
            return image
        }

        if let cachedData = try? await diskCache.retrieve(forKey: url),
           let image = UIImage(data: cachedData) {
            await memoryCache.store(image, forKey: url)
            return image
        }

        return nil
    }
}
