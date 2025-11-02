//
//  ImageDownloader.swift
//  Prism
//
//  Created by 제민우 on 10/31/25.
//

import Foundation
import os

final class ImageDownloader {
    
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    func fetchImage(from url: URL?) async throws(PrismError) -> Data {
        guard let url else {
            throw .networkError(reason: .invalidURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await urlSession.data(for: request)
            try validateResponse(data: data, response: response)
            return data
        } catch {
            PrismLogger.network.error("URLSession 에러")
            throw .networkError(reason: .urlSessionFailed(error))
        }
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
