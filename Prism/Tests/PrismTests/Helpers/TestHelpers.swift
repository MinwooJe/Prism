//
//  TestHelpers.swift
//  Prism
//
//  Created by MinwooJe on 3/21/26.
//

import UIKit

enum TestHelpers {

    static func makeURL(path: String = "test.png") -> URL {
        URL(string: "https://example.com/\(path)")!
    }

    static func makeTestImageData(with color: UIColor = .blue) -> Data {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()!
    }

    static func makeTestImage(with color: UIColor = .blue) -> UIImage {
        return UIImage(data: makeTestImageData(with: color))!
    }

}
