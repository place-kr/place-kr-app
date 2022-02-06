//
//  UserFetchManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/06.
//

import Foundation

class AuthAPIManager {
    static func sendPostRequest(to url: URL, body: PostBody.Apple, then handler: @escaping (Result<Data, Error>) -> Void) {
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
        print(String(data: encodedBody, encoding: String.Encoding.utf8))
        let task = session.uploadTask(with: request, from: encodedBody) { data, response, error in
            if let error = error {
                print("Error while uploading")
                completionHandler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse, !((200...300).contains(response.statusCode)) {
//                print(response as Any)
                completionHandler(.failure(FetchError.invalidResponse))
                // Peek into response if error occurs
            }
            print(response as Any)

            guard let data = data else {
                completionHandler(.failure(FetchError.invalidData))
                print("Error in data")
                return
            }

            let decoder = JSONDecoder()
            guard let jsonData = try? decoder.decode(PostReponse.self, from: data) else {
                print("Error while parsing")
                return
            }
            
            print(jsonData.getDescription())
        }
        task.resume()
    }
}

extension AuthAPIManager {
    enum FetchError: Error {
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
            }
        }
    }
    
    struct PostBody {
        struct Naver: Codable {
            let identifier: String
            let email: String
            let accessToken: String
            
            enum CodingKeys : String, CodingKey{
                case identifier
                case email
                case accessToken = "access_token"
            }
        }
        
        struct Apple: Codable {
            let identifier: String
            let email: String
            let idToken: String
            
            enum CodingKeys : String, CodingKey{
                case identifier
                case email
                case idToken = "identity_token"
            }
        }
    }
    
    struct PostReponse: Codable {
        let success: Bool
        let result: Response
        
        struct Response: Codable {
            let token: String
        }
        
        func getDescription() {
            print("Token: \(self.result.token)")
        }
    }
}
