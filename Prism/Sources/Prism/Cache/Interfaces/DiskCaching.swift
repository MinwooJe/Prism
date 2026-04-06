//
//  DiskCaching.swift
//  Prism
//
//  Created by MinwooJe on 4/6/26.
//

import Foundation

public protocol DiskCaching: Sendable {
    func retrieve(forKey url: URL) async -> Data?
    func store(_ data: Data, forKey url: URL) async throws(PrismError)
    func remove(forKey url: URL) async throws(PrismError)
}
