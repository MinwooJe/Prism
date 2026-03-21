//
//  DemoView.swift
//  Prism
//
//  Created by MinwooJe on 3/22/26.
//

import SwiftUI

struct DemoView: View {

    private let imageURLs: [URL?] = (1...30).map { URL(string: "https://picsum.photos/seed/\($0)/400/600")}

    init() { }

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("AsyncImage vs PrismImage")

                NavigationLink {
                    AsyncImageDemoView(imageURLs: imageURLs)
                } label: {
                    Text("AsyncImage Demo")
                }

                NavigationLink {
                    PrismDemoView(imageURLs: imageURLs)
                } label: {
                    Text("PrismImage Demo")
                }
            }
        }
    }

}

#Preview {
    DemoView()
}
