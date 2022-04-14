//
//  RegisterManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/14.
//

import Combine
import Foundation

struct RegisterRequest: Codable, Identifiable {
    let id = UUID()
    let name: String
    var x: String? = nil
    var y: String? = nil
    let address: String
    var addressDetail: String? = nil
    var descriptions: String? = nil
    var status: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case name, address, descriptions, status, x, y
        case addressDetail = "address_detail"
    }
    
    var parsedStatus: String {
        switch self.status {
        case "REQUESTED":
            return "접수중"
        case "FAILED":
            return "등록실패"
        case "SUCCESSED":
            return "등록완료"
        default:
            return "알 수 없음"
        }
    }
}

struct RegisterRequestList: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RegisterRequest]
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
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode
                else {
                    throw URLError(.badServerResponse)
                }
                
                return true
            }
            .eraseToAnyPublisher()
    }
    
    static func fetchRequests() -> AnyPublisher<RegisterRequestList, Error> {
        guard let request = self.authorizedRequest else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                print(response)
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode
                else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: RegisterRequestList.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
