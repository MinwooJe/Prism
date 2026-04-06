//
//  ImageDownloading.swift
//  Prism
//
//  Created by MinwooJe on 3/20/26.
//

import Foundation

public protocol ImageDownloading: Sendable {
    func fetchImage(from url: URL) async throws(PrismError) -> Data
}
