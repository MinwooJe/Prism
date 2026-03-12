//
//  CacheKey.swift
//  Prism
//
//  Created by MinwooJe on 3/12/26.
//

import CryptoKit
import Foundation

struct CacheKey: Sendable {
    let value: String

    init(url: URL) {
        self.value = Self.sha256(for: url)
    }
}

extension CacheKey {
    private static func sha256(for url: URL) -> String {
        let urlString = url.absoluteString
        let data = Data(urlString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
