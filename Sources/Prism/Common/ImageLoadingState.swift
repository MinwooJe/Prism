//
//  ImageLoadingState.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import UIKit

public enum ImageLoadingState: Sendable {
    case loading
    case success(image: UIImage)
    case failed(PrismError)
}
