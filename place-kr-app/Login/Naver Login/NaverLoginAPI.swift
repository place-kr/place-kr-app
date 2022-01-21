import Combine
import Foundation

struct response_naver_login: Codable {
    let resultcode: String
    let message: String
    let response: NaverUserData
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


