//
//  MemoryCache.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import UIKit

private final class Item {
    let key: URL
    let value: UIImage
    var previous: Item?
    var next: Item?
    var cost: Int {
        Int((value.size.width * value.scale) * (value.size.height * value.scale) * 4)
    }

    init(key: URL, value: UIImage, previous: Item? = nil, next: Item? = nil) {
        self.key = key
        self.value = value
        self.previous = previous
        self.next = next
    }
}

/// 이중 연결 리스트와 해시맵을 조합한 LRU(Least Recently Used) 메모리 캐시입니다.
///
/// - 조회(`retrieve`)와 저장(`store`) 모두 O(1) 시간 복잡도로 동작합니다.
/// - 캐시가 `totalCostLimit`에 도달하면 가장 오래전에 사용된 항목부터 자동으로 제거됩니다.
/// - cost는 이미지 픽셀 수 × 4바이트(RGBA) 기준으로 산정됩니다.
/// - NSLock을 사용해 Thread-safe를 보장합니다.
final class MemoryCache: @unchecked Sendable {
    private let totalCostLimit: Int
    private var totalCost = 0

    private var entries = [URL: Item]()

    // Sentinel Node: 실제 데이터를 담지 않는 더미 노드로 value와 key는 사용되지 않습니다.
    private var head: Item = .init(key: URL(string: "sentinel://head")!, value: .init())
    private var tail: Item = .init(key: URL(string: "sentinel://tail")!, value: .init())

    private let lock = NSLock()

    static let shared = MemoryCache()

    /// - Parameter totalCostLimit: 캐시가 허용하는 최대 메모리 비용 (바이트 단위).
    ///   개별 이미지의 cost가 이 값을 초과하면 저장되지 않습니다.
    init(totalCostLimit: Int = 50 * 1024 * 1024) {
        self.totalCostLimit = totalCostLimit
        head.next = tail
        tail.previous = head
    }

    /// 주어진 URL에 해당하는 캐시된 이미지를 반환합니다.
    ///
    /// 캐시 히트 시 해당 항목을 MRU(Most Recently Used) 위치로 이동시킵니다.
    ///
    /// - Parameter url: 이미지를 식별하는 URL 키.
    /// - Returns: 캐시된 이미지. 캐시 미스 시 `nil`을 반환합니다.
    func retrieve(forKey url: URL) -> UIImage? {
        lock.withLock {
            if let item = entries[url] {
                removeItem(item)
                insertFirst(item)
                return item.value
            }

            return nil
        }
    }

    /// 이미지를 캐시에 저장합니다.
    ///
    /// - 동일한 URL 키가 이미 존재하면 기존 항목을 제거하고 새 항목으로 교체합니다.
    /// - 저장 후 `totalCostLimit`을 초과할 경우, 한도 내에 들어올 때까지 LRU 항목부터 순차적으로 제거합니다.
    /// - 이미지의 크기가 `totalCostLimit`을 초과하면 캐싱하지 않습니다.
    ///
    /// - Parameters:
    ///   - image: 캐시할 이미지.
    ///   - url: 이미지를 식별하는 URL 키.
    func store(_ image: UIImage, forKey url: URL) {
        lock.withLock {
            if let item = entries[url] {
                removeItem(item)
            }

            let newItem = Item(key: url, value: image)

            guard newItem.cost <= totalCostLimit else { return }

            while totalCost + newItem.cost > totalCostLimit {
                guard evictLRU() else { break }
            }

            insertFirst(newItem)
        }
    }

    /// 주어진 URL에 해당하는 항목을 캐시에서 제거합니다.
    ///
    /// 캐시에 해당 항목이 없으면 아무 동작도 하지 않습니다.
    ///
    /// - Parameter url: 제거할 이미지를 식별하는 URL 키.
    func remove(forKey url: URL) {
        lock.withLock {
            if let item = entries[url] {
                removeItem(item)
            }
        }
    }

}

extension MemoryCache {

    private func insertFirst(_ item: Item) {
        item.next = head.next
        item.previous = head
        head.next?.previous = item
        head.next = item

        entries[item.key] = item

        totalCost += item.cost
    }

    private func removeItem(_ item: Item) {
        item.previous?.next = item.next
        item.next?.previous = item.previous

        entries[item.key] = nil

        totalCost -= item.cost
    }

    private func evictLRU() -> Bool {
        guard let lru = tail.previous,
              lru !== head
        else {
            return false
        }

        removeItem(lru)

        return true
    }

}
