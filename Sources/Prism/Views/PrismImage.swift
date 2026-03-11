//
//  PrismImage.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import SwiftUI

struct PrismImage<Content: View>: View {

    private let url: URL?
    private let size: CGSize?
    private let content: (ImageLoadingState) -> Content

    @State private var state: ImageLoadingState = .loading

    private let imageRepository: ImageRepository = .shared

    init(
        url: URL?,
        size: CGSize? = nil,
        @ViewBuilder content: @escaping (ImageLoadingState) -> Content
    ) {
        self.url = url
        self.size = size
        self.content = content
    }

    var body: some View {
        Group {
            if let size {
                content(state)
                    .frame(width: size.width, height: size.height)
            } else {
                content(state)
            }
        }
        .task {
            await fetchImage(from: url)
        }
    }

}

extension PrismImage {

    private func fetchImage(from url: URL?) async {
        for await state in imageRepository.fetchImage(from: url) {
            switch state {
            case .loading:
                self.state = .loading
            case .success(let image):
                self.state = .success(image: image)
            case .failed(let prismError):
                self.state = .failed(prismError)
            }
        }
    }

}
