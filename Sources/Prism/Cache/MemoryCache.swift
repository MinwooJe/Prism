//
//  MemoryCache.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import UIKit

actor MemoryCache {

    private let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()

    static let shared = MemoryCache()

    init() { }

    func retrieve(forKey url: URL) -> UIImage? {
        return memoryCache.object(forKey: url.absoluteString as NSString)
    }

    func store(_ image: UIImage, forKey url: URL) {
        let cost = Int((image.size.width * image.scale) * (image.size.height * image.scale) * 4)
        memoryCache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }

    func remove(forKey url: URL) {
        memoryCache.removeObject(forKey: url.absoluteString as NSString)
    }

}
