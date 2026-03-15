//
//  ImageDownloader.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import Foundation
import os

final class ImageDownloader: Sendable {

    private let urlSession: URLSession

    init(
        urlSession: URLSession = .shared
    ) {
        self.urlSession = urlSession
    }

    func fetchImage(from url: URL) async throws(PrismError) -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            let networkError = PrismError.networkError(reason: .urlSessionFailed(error))
            PrismLogger.network.error("\(networkError)")
            throw networkError
        }

        try validateResponse(data: data, response: response)

        return data
    }

}

extension ImageDownloader {

    private func validateResponse(data: Data, response: URLResponse) throws(PrismError) {
        guard let httpResponse = response as? HTTPURLResponse else {
            PrismLogger.network.error("\(PrismError.NetworkErrorReason.invalidResponse)")
            throw .networkError(reason: .invalidResponse)
        }

        guard (200..<400).contains(httpResponse.statusCode) else {
            let statusCode = httpResponse.statusCode
            PrismLogger.network.error(
                "\(PrismError.NetworkErrorReason.serverError(code: .init(fromRawValue: statusCode))), Code: \(statusCode)"
            )
            throw .networkError(reason: .serverError(code: .init(fromRawValue: statusCode)))
        }

        guard !data.isEmpty else {
            throw .networkError(reason: .emptyData)
        }
    }

}
