//
//  RegisterManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/14.
//

import Combine
import Foundation

struct RegisterRequest: Encodable {
    let name: String
    let address: String
}

class RegisterManager: ObservableObject {
    static var authorizedRequest: URLRequest? {
        guard let baseUrl = URL(string: "https://dev.place.tk/api/v1/me/places/register") else {
            return nil
        }
        guard let token = UserInfoManager.userToken else {
            return nil
        }
         
        var request = URLRequest(url: baseUrl)
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    static func registerPlace(_ body: RegisterRequest) -> AnyPublisher<Bool, Error> {
        guard var request = self.authorizedRequest else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        guard let encoded = try? JSONEncoder().encode(body) else {
            return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
        }
        
        request.httpBody = encoded
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { _, response in
                print(response)
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode
                else {
                    throw URLError(.badServerResponse)
                }
                
                return true
            }
            .eraseToAnyPublisher()
    }
}
