//
//  PrismDemoView.swift
//  Prism
//
//  Created by MinwooJe on 3/22/26.
//

import SwiftUI

import Prism

struct PrismDemoView: View {
    private let imageURLs: [URL?]

    init(imageURLs: [URL?]) {
        self.imageURLs = imageURLs
    }

    var body: some View {
        ImageGridLayout(imageURLs: imageURLs) { url in
            PrismImage(url: url) { state in
                switch state {
                case .loading:
                    ProgressView()
                case .success(let image):
                    Image(uiImage: image)
                        .resizable()
                case .failed:
                    Color.red
                }
            }
        }
        .navigationTitle("PrismImage Demo")
    }
}

#Preview {
    DemoView()
}
