//
//  MemoryCacheTests.swift
//  Prism
//
//  Created by MinwooJe on 4/6/26.
//

import Testing
import UIKit
@testable import Prism

struct MemoryCacheTests {

    // MARK: - removeAll Tests

    @Test
    func removeAll_호출후_모든항목이_nil반환() {
        let sut = MemoryCache()
        let urls = (0..<3).map { TestHelpers.makeURL(path: "remove\($0).png") }
        let image = TestHelpers.makeTestImage()

        for url in urls {
            sut.store(image, forKey: url)
        }

        sut.removeAll()

        for url in urls {
            let result = sut.retrieve(forKey: url)
            #expect(result == nil)
        }
    }

    @Test
    func removeAll_호출후_totalCost가_0으로_초기화() {
        let sut = MemoryCache(totalCostLimit: 50 * 1024 * 1024)
        let urls = (0..<3).map { TestHelpers.makeURL(path: "cost\($0).png") }
        let image = TestHelpers.makeTestImage()

        for url in urls {
            sut.store(image, forKey: url)
        }

        sut.removeAll()

        let newURL = TestHelpers.makeURL(path: "after_clear.png")
        sut.store(image, forKey: newURL)
        let result = sut.retrieve(forKey: newURL)
        #expect(result != nil)
    }

}
