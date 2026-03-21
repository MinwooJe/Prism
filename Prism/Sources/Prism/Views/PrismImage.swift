//
//  PrismImage.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import SwiftUI

public struct PrismImage<Content: View>: View {

    private let url: URL?
    private let size: CGSize?
    private let content: (ImageLoadingState) -> Content

    @State private var state: ImageLoadingState = .loading

    private let imageRepository: ImageService = .shared

    public init(
        url: URL?,
        size: CGSize? = nil,
        @ViewBuilder content: @escaping (ImageLoadingState) -> Content
    ) {
        self.url = url
        self.size = size
        self.content = content
    }

    public var body: some View {
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
        for await state in await imageRepository.imageStream(from: url) {
            self.state = state
        }
    }

}
