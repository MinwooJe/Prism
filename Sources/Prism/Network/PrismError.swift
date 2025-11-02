//
//  PrismError.swift
//  Prism
//
//  Created by 제민우 on 10/31/25.
//

import Foundation

public enum PrismError: Error {

    public enum NetworkErrorReason {

        /// 유효하지 않은 URL 문자열로 인해 URL 생성에 실패한 경우
        case invalidURL

        /// URLSession 네트워크 요청 자체가 실패한 경우 (인터넷 끊김, 타임아웃 등)
        case urlSessionFailed(Error)

        /// response가 HTTPURLResponse로 다운 캐스팅 실패한 경우
        case invalidResponse

        /// 서버가 실패 응답을 반환한 경우 (4xx 또는 5xx)
        /// - code: HTTP 상태 코드
        /// - message: 서버가 전달한 에러 메시지 (Optional)
        case serverError(code: HTTPErrorCode)

        /// 데이터가 비어있는 경우
        case emptyData

    }

    public enum ProcessingErrorReason {
        case processingFailed
    }


    case networkError(reason: NetworkErrorReason)
    case processingError(reason: ProcessingErrorReason)
    case unknown(Error? = nil)

}



extension PrismError.NetworkErrorReason: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "invalidURL) 예시: URLComponents(string: baseURL) 생성 실패."
        case .urlSessionFailed(let error):
            return "urlSessionFailed) 네트워크 요청 중 URLSession 에러 발생: \(error.localizedDescription)"
        case .invalidResponse:
            return "invalidResponse) 응답 객체가 HTTPURLResponse 형식이 아님. 유효한 HTTP 응답이 아님."
        case let .serverError(code):
            return "serverError) 상태 코드: \(code), 설명: \(code.errorDescription ?? "없음.")"
        case .emptyData:
            return "emptyData) 응답은 정상적으로 도착했으나, 데이터가 비어 있거나 존재하지 않음."
        }
    }
    
    public enum HTTPErrorCode: Int, LocalizedError {
        /// 인증 실패 (ex. 토큰 없음, 만료, 잘못된 자격 증명 등)
        case unauthorized = 401
        
        /// 요청한 리소스를 서버에서 찾을 수 없음
        case notFound = 404
        
        /// 인증 실패 또는 endpoint가 spam 처리 됨.
        case validationFailed = 422
        
        /// 알 수 없는 에러 혹은 현재 열거형에 정의되지 않은 에러
        case unknown
        
        init(fromRawValue rawValue: Int) {
            self = HTTPErrorCode(rawValue: rawValue) ?? .unknown
        }
        
        public var errorDescription: String? {
            let code = self.rawValue
            switch self {
            case .unauthorized:
                return "\(code) Unauthorized: 인증 정보가 없거나 유효하지 않습니다."
            case .validationFailed:
                return "\(code) Validation Failed: 인증 정보가 없거나 유효하지 않습니다. 또는 스팸처리 되었으니 시간을 두고 다시 시도하세요."
            case .notFound:
                return "\(code) Not Found: 요청한 리소스를 서버에서 찾을 수 없습니다."
            case .unknown:
                return "Unknown: 정의되지 않은 서버 오류입니다."
            }
        }
    }
    
}
