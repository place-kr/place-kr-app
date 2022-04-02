//
//  FavoritePlacesManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/29.
//

import Combine
import Foundation
import SwiftUI

struct PlaceListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PlaceList]
}

struct PlaceList: Codable, Hashable {
    let identifier: String
    let name: String
    let icon: String
    let color: String
    let places: [String]
    let count: Int
    
    static func == (lhs: PlaceList, rhs: PlaceList) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier, name, places
        case icon = "label_icon"
        case color = "label_color"
        case count = "places_count"
    }
}

struct PlaceListPostBody: Encodable {
    let name: String
    let icon: String
    let color: String
    let places: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, places
        case icon = "label_icon"
        case color = "label_color"
    }
}

class ListManager: ObservableObject {
    @Published var placeLists: [PlaceList]
    
    private var subscriptions = Set<AnyCancellable>()
    private let baseUrl = URL(string: "https://dev.place.tk/api/v1/")!

    private func authroizedRequest(with components: String,
                                   method: String,
                                   body: PlaceListPostBody? = nil,
                                   completionHandler: ((Bool) -> ())? = nil) -> URLRequest? {
        let url = baseUrl.appendingPathComponent(components)
        guard let token = UserInfoManager.userToken else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body, let encoded = try? JSONEncoder().encode(body) {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = encoded
            
            print(encoded)
        }
        return request
    }
   
    /// 플레이스 리스트 받아오기. 퍼블리셔 타입.
    func getPlaceLists() -> AnyPublisher<[PlaceList], Error> {
        guard let request = authroizedRequest(with: "me/lists", method: "GET") else {
            return Fail(error: HTTPError.url).eraseToAnyPublisher()
        }
        let session = URLSession.shared
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    print("Place list error: \(response)")
                    switch (response as! HTTPURLResponse).statusCode {
                    case (400...499):
                        throw HTTPError.response
                    default:
                        throw HTTPError.response
                    }
                }
                
                return data
            }
            .tryMap { data in
                let decoded = try JSONDecoder().decode(PlaceListResponse.self, from: data)
                return decoded.results
            }
            .eraseToAnyPublisher()
    }
    
    /// 새로운 플레이스 추가. 컴플리션으로 성공 여부 받을 수 있음.
    func addPlaceList(body: PlaceListPostBody, completionHandler: ((Bool) -> ())? = nil) {
        guard let request = authroizedRequest(with: "me/lists", method: "POST", body: body) else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            print("Place list url error")
            return
        }
        let session = URLSession.shared
        
        session.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode
            else {
                print("Place list response error: \(response as Any)")
                switch (response as! HTTPURLResponse).statusCode {
                case (400...499):
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                    return
                default:
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                    return
                }
            }
        }
        .resume()
        
        
        if let completionHandler = completionHandler {
            completionHandler(true)
        }
        self.updateLists()
    }
    
    /// 플레이스 리스트 삭제
    func deletePlaceList(id: String, completionHandler: ((Bool) -> ())? = nil) {
        guard let request = authroizedRequest(with: "me/lists/\(id)", method: "DELETE") else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            return
        }
        let session = URLSession.shared
        
        session.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                switch (response as! HTTPURLResponse).statusCode {
                case (400...499):
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                    return
                default:
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                    return
                }
            }
        }
        
        if let completionHandler = completionHandler {
            completionHandler(true)
        }
    }
    
    /// 플레이스 리스트 수정
    func patchPlaceList(id: String, body: PlaceListPostBody, completionHandler: ((Bool) -> ())? = nil) {
        guard let request = authroizedRequest(with: "me/lists/\(id)", method: "PATCH", body: body) else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            return
        }
        let session = URLSession.shared
        
        session.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                switch (response as! HTTPURLResponse).statusCode {
                case (400...499):
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                    return
                default:
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                    return
                }
            }
        }
        
        if let completionHandler = completionHandler {
            completionHandler(true)
        }
    }
    
    /// 퍼블리셔로 리스트 업데이트 하는 루틴
    private func updateLists() {
        self.getPlaceLists()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("Place list fetched")
                case .failure(let error):
                    print("Error while fetching place lists: \(error)")
                
                }
            }, receiveValue: { data in
                print(data)
                self.placeLists = data
            })
            .store(in: &subscriptions)
    }
    
    init() {
        self.placeLists = [PlaceList]()
        self.updateLists()
    }
}

enum HTTPError: LocalizedError {
    case url
    case network
    case response
    case encoding
    case decoding
    case data
    
    var localizedDescription: String {
        switch self {
        case .url: return NSLocalizedString("URL", comment: "URL Error")
        case .network: return NSLocalizedString("Network", comment: "Error in connection")
        case .encoding: return NSLocalizedString("Encoding", comment: "Error occured while encoding data")
        case .decoding: return NSLocalizedString("Decoding", comment: "Error occured while decoding data")
        case .response: return NSLocalizedString("Response", comment: "Error occured while networking")
        case .data: return NSLocalizedString("Data", comment: "Error occured while networking")

        }
    }
}
