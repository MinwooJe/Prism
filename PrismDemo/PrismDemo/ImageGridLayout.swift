//
//  ImageGridLayout.swift
//  Prism
//
//  Created by MinwooJe on 3/22/26.
//

import SwiftUI

struct ImageGridLayout<Content>: View where Content: View {

    private let imageURLs: [URL?]
    private let content: (URL?) -> Content
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    init(imageURLs: [URL?], content: @escaping (URL?) -> Content) {
        self.imageURLs = imageURLs
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, url in
                    content(url)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                }
            }
        }
    }

}
