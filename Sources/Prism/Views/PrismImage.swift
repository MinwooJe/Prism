//
//  PrismImage.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import SwiftUI

struct PrismImage: View {

    private let state: ImageLoadingState
    private let size: CGSize

    init(
        state: ImageLoadingState,
        size: CGSize,
        onAppear: @escaping () -> Void,
    ) {
        self.state = state
        self.size = size
    }

    public var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView()
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
            case .failed:
                Image(systemName: "person")
                    .resizable()
            }
        }
        .frame(width: size.width, height: size.height)
    }

}
