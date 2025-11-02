//
//  ImageRepository.swift
//  Prism
//
//  Created by 제민우 on 10/29/25.
//

import UIKit

fileprivate extension AsyncStream.Continuation {
    /// yield와 finish를 한번에 수행하는 헬퍼 메서드입니다.
    func yieldAndFinish(_ value: sending Element) {
        self.yield(value)
        self.finish()
    }
}

final class ImageRepository: @unchecked Sendable {
    
    private let imageDownloader: ImageDownloader
    private let imageCache: ImageCache
    
    init(
        imageDownloader: ImageDownloader = ImageDownloader(),
        imageCache: ImageCache
    ) {
        self.imageDownloader = imageDownloader
        self.imageCache = imageCache
    }
    
    /// ImageLoadState의 AsyncStream을 즉시 반환합니다.
    ///
    /// 에러는 Stream 내부 Task에서 발생하므로 throws function이 아닙니다.
    func fetchImage(from url: URL?) -> AsyncStream<ImageLoadingState> {
        AsyncStream { continuation in
            Task { @Sendable in
                continuation.yield(.empty)
                
                guard let url else {
                    continuation.yield(.failed(.networkError(reason: .invalidURL)))
                    continuation.finish()
                    return
                }
                
                let urlString = url.absoluteString
                
                if let cachedImage = await imageCache.retrieve(forKey: urlString) {
                    continuation.yieldAndFinish(.loaded(image: cachedImage))
                    return
                }
                
                continuation.yield(.loading)
                
                do {
                    let imageData = try await imageDownloader.fetchImage(from: url)
                    
                    guard let image = UIImage(data: imageData) else {
                        throw PrismError.processingError(reason: .processingFailed)
                    }
                    
                    await imageCache.store(image, forKey: urlString)
                    continuation.yieldAndFinish(.loaded(image: image))
                    
                } catch let error as PrismError {
                    continuation.yieldAndFinish(.failed(error))
                }
            }
        }
    }
    
}
