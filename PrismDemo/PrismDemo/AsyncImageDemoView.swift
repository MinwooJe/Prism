//
//  AsyncImageDemoView.swift
//  Prism
//
//  Created by MinwooJe on 3/22/26.
//

import SwiftUI

struct AsyncImageDemoView: View {

    private let imageURLs: [URL?]

    init(imageURLs: [URL?]) {
        self.imageURLs = imageURLs
    }

    var body: some View {
        ImageGridLayout(imageURLs: imageURLs) { url in
            AsyncImage(url: url) { phase in
                if case .empty = phase {
                    ProgressView()
                } else if case .success(let image) = phase {
                    image
                        .resizable()
                } else if case .failure = phase {
                    Color.red
                }
            }
        }
        .navigationTitle("AsyncImage Demo")
    }

}
