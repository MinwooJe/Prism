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

    static let shared = ImageRepository()

    init(
        imageDownloader: ImageDownloader = ImageDownloader(),
        memoryCache: MemoryCache = MemoryCache.shared
    ) {
        self.imageDownloader = imageDownloader
        self.memoryCache = memoryCache
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

                if let cachedImage = await memoryCache.retrieve(forKey: url) {
                    continuation.yieldAndFinish(.success(image: cachedImage))
                    return
                }

                do {
                    let imageData = try await imageDownloader.fetchImage(from: url)

                    guard let image = UIImage(data: imageData) else {
                        throw PrismError.processingError(reason: .processingFailed)
                    }

                    await memoryCache.store(image, forKey: url)
                    continuation.yieldAndFinish(.success(image: image))

                } catch let error as PrismError {
                    continuation.yieldAndFinish(.failed(error))
                } catch {
                    continuation.yieldAndFinish(.failed(.unknown(error)))
                }
            }
        }
    }

}
