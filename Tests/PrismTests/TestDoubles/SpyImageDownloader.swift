//
//  SpyImageDownloader.swift
//  Prism
//
//  Created by MinwooJe on 3/20/26.
//

import Foundation
@testable import Prism

/// @unchecked Sendable: 테스트 전용 Stub으로, 각 테스트가 독립적인 인스턴스를 생성하여 동시 접근이 발생하지 않도록 안정성을 보장해야 합니다.
final class SpyImageDownloader: ImageDownloading, @unchecked Sendable {
    var stubbedImageData: Data?
    var stubbedError: PrismError?
    var fetchCallCount = 0
    var lastRequestURL: URL?

    func fetchImage(from url: URL) async throws(PrismError) -> Data {
        fetchCallCount += 1
        lastRequestURL = url

        if let stubbedError {
            throw stubbedError
        }

        guard let stubbedImageData else {
            throw .networkError(reason: .emptyData)
        }

        return stubbedImageData
    }

}
