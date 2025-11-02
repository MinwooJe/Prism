//
//  ImageLoadingState.swift
//  Prism
//
//  Created by 제민우 on 10/31/25.
//

import UIKit

enum ImageLoadingState: Sendable {
    case empty
    case loading
    case loaded(image: UIImage)
    case failed(PrismError)
}
