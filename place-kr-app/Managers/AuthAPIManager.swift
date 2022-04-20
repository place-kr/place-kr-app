//
//  UserFetchManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/06.
//

import Foundation

protocol PostRequest: Encodable {}


class AuthAPIManager {
    typealias Response = AuthAPIManager.PostReponse
    
    /// 바디를 실어서 API서버에 토큰을 요청하는 루틴입니다. Naver, Apple 로그인 상관 없음.
    /// 리턴은 없고 컴플리션으로 Result 객체를 전달합니다.
    static func sendPostRequest<T: PostRequest>(to url: URL, body: T, then handler: @escaping (Result<Response, Error>) -> Void) {
        let completionHandler = handler
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        
        // Encoding received body
        let encoder = JSONEncoder()
        guard let encodedBody = try? encoder.encode(body) else {
            print("Error while encoding")
            // TODO: Error handle
            return
        }
        
        // Post settings
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Peek into request body
        let task = session.uploadTask(with: request, from: encodedBody) { data, response, error in
            if let error = error {
                print("Error while uploading")
                completionHandler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse, !((200...300).contains(response.statusCode)) {
                print(response as Any)
                print("Error in response. May be a network error.")
                completionHandler(.failure(FetchError.invalidResponse))
                // Peek into response if error occurs
            }
            
            guard let data = data else {
                print("Error in data")
                completionHandler(.failure(FetchError.invalidData))
                return
            }

            let decoder = JSONDecoder()
            guard let decodedResponse = try? decoder.decode(PostReponse.self, from: data) else {
                print("Error while parsing")
                print(String(data: data, encoding: String.Encoding.utf8) as Any)
                completionHandler(.failure(FetchError.parsing))
                return
            }
            
            print("Successed to get token from API server: \(decodedResponse.token)")
            completionHandler(.success(decodedResponse))
        }
        task.resume()
    }
    
    /// 닉네임 서버에 등록
    static func updateUserData(nickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var request = authorizedRequest(method: "PATCH", api: "/me") else {
            return
        }
        
        let body = UserDataPostRequest(nickname: nickname, categories: ["1", "2"])
        guard let encoded = try? JSONEncoder().encode(body) else {
            return
        }
        
        request.httpBody = encoded
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let response = response as? HTTPURLResponse, !((200...300).contains(response.statusCode)) {
                print(response as Any)
                print("Error in response. May be a network error.")
                completion(.failure(FetchError.invalidResponse))
            }
            
            completion(.success(()))
        }
    }
}

extension AuthAPIManager {
    private struct UserDataPostRequest: Encodable {
        let nickname: String
        let categories: [String]
    }
    
    enum FetchError: Error {
        case parsing
        case expiredToken
        case invalidData
        case invalidResponse
        
        var description: String {
            switch self {
            case .expiredToken:
                return "Token is invalid. It could be expired."
            case .invalidResponse:
                return "Invalid network response."
            case .invalidData:
                return "Wrong data"
            case .parsing:
                return "Error while parsing"
            }
        }
    }

    struct NaverBody: Codable, PostRequest {
        let identifier: String
        let email: String
        let accessToken: String
        
        enum CodingKeys : String, CodingKey{
            case identifier
            case email
            case accessToken = "access_token"
        }
    }
    
    struct AppleBody: Codable, PostRequest {
        let identifier: String
        let email: String
        let idToken: String
        
        enum CodingKeys : String, CodingKey{
            case identifier
            case email
            case idToken = "identity_token"
        }
    }
    
    struct PostReponse: Codable {
        let token: String
        let isRegistered: Bool
        
        enum CodingKeys: String, CodingKey {
            case token
            case isRegistered = "is_onboarding_required"
        }
    }
}
