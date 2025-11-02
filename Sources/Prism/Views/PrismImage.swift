//
//  PrismImage.swift
//  Prism
//
//  Created by 제민우 on 11/3/25.
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
            case .empty:
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            case .loading:
                ProgressView()
            case .loaded(let image):
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
