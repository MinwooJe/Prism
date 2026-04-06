//
//  MemoryCaching.swift
//  Prism
//
//  Created by MinwooJe on 4/6/26.
//

import UIKit

public protocol MemoryCaching: Sendable {
    func retrieve(forKey url: URL) -> UIImage?
    func remove(forKey url: URL)
    func store(_ image: UIImage, forKey url: URL)
}
