import Combine
import Foundation

struct NaverLoginResponse: Codable {
    let id: String          /// 동일인 식별 정보 - 동일인 식별 정보는 네이버 아이디마다 고유하게 발급되는 값
    let name: String        /// 사용자 이름
    let email: String       /// 사용자 메일 주소
    let nickname: String?   /// 사용자 별명
    let gender: String?     /// F: 여성 M: 남성 U: 확인불가
    let age: String?        /// 사용자 연령대
    let birthday: String?   /// 사용자 생일(MM-DD 형식)
    let profile_image: String?      /// 사용자 프로필 사진 URL
}

struct response_naver_login: Codable {
    let resultcode: String
    let message: String
    let response: NaverLoginResponse
}

// MARK: 네이버 간편로그인 이후 데이터를 받아오기 위해서 사용되는 API
enum NaverLoginRouter {
    case naverLogin(tokenType: String, accessToken: String)
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameter: [String: String], body: [String: Any], header: [String: String], method: String) = {
            switch self {
            case let .naverLogin(tokenType, accessToken):
                return ("", [:], [:], ["Authorization": "\(tokenType) \(accessToken)"], "GET")
            }
        }()
        
        guard var urlComponent = URLComponents(string: "https://openapi.naver.com/v1/nid/me" + result.path) else {
            //            APIError.invalidEndpoint
            fatalError("APIError.invalidEndpoint") // handle error
        }
        urlComponent.queryItems = result.parameter.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        guard let url = urlComponent.url else {
            //            APIError.invalidEndpoint
            fatalError("APIError.invalidEndpoint")
        }
        var request = URLRequest(url: url)
        request.httpMethod = result.method
        
        // 헤더 설정
        request.addValue(result.header["Authorization"]!, forHTTPHeaderField: "Authorization")
        
        return request
    }
}

/// 네이버 간편 로그인
private func naverLoginSession(tokenType: String, accessToken: String, session: URLSession = URLSession.shared) throws -> URLSession.DataTaskPublisher {
    let request = try NaverLoginRouter.naverLogin(tokenType: tokenType, accessToken: accessToken).asURLRequest()
    return session.dataTaskPublisher(for: request)
}

func NaverLogin(tokenType: String, accessToken: String) throws -> AnyPublisher<response_naver_login, Error>? {
    return try? naverLoginSession(tokenType: tokenType, accessToken: accessToken)
        .map(\.data)
        .decode(type: response_naver_login.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}


