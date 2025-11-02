//
//  ImageCache.swift
//  Prism
//
//  Created by 제민우 on 10/29/25.
//

import UIKit

public actor ImageCache {

    private let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()
    
    public static let shared = ImageCache()
    
    public init() { }

    public func retrieve(forKey key: String) async -> UIImage? {
        return memoryCache.object(forKey: key as NSString)
    }

    /// 이미지를 캐시에 저장합니다.
    ///
    /// **저장 전략:**
    /// - 메모리: 동기적으로 즉시 저장 (빠름)
    /// - 디스크: 비동기로 저장 (느림)
    ///
    /// **에러 처리를 하지 않는 이유**
    /// - 메모리 저장은 거의 실패하지 않음
    /// - 디스크 저장 실패해도 메모리 캐시는 동작
    /// - Fire-and-forget 전략: 저장 실패를 치명적 오류로 간주하지 않음
    public func store(_ image: UIImage, forKey key: String) async {
        let cost = Int(image.size.width * image.size.height * 4)
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)
    }

    public func remove(forKey key: String) async {
        memoryCache.removeObject(forKey: key as NSString)
    }

}
