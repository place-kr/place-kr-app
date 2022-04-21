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
    var name: String
    var icon: String
    var color: String
    var places: [String]
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

protocol HTTPBody {}

struct PlaceListPostBody: Encodable  {
    var name: String? = nil
    var icon: String? = nil
    var color: String? = nil
    let places: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, places
        case icon = "label_icon"
        case color = "label_color"
    }
}

struct ListBody: Encodable {
    let places: [String]

    enum CodingKeys: String, CodingKey {
        case places
    }
}

struct NameBody: Encodable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct ErrorBody: Decodable {
    let message: String?
    let details: Details?
    
    enum CodingKeys: String, CodingKey {
        case message, details
    }
    struct Details: Decodable {
        let places: [String]
        
        enum CodingKeys: String, CodingKey {
            case places
        }
    }
}

class ListManager: ObservableObject {
    @Published var placeLists: [PlaceList]
    
    private var nextPageUrl: URL? = nil
    private var subscriptions = Set<AnyCancellable>()
    private let baseUrl = URL(string: "https://dev.place.tk/api/v1")!
    
    /// 리스트에 플레이스 1개 더하기
    func addOnePlaceToList(listID: String, placeID: String, completionHandler: ((Bool) -> ())? = nil) {
        let queryItems = [
            URLQueryItem(name: "add_place_identifier", value: "\(placeID)")
        ]
        
        guard let request = authorizedRequest(method: "PATCH", api: "/me/lists/\(listID)", queryItems: queryItems) else {
            
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            print("Place list url error")
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode
            else {
                print("Place list response error: \(response as Any)")
                
                if let completionHandler = completionHandler {
                    completionHandler(false)
                }
                return
            }
            
            if let completionHandler = completionHandler {
                completionHandler(true)
                print("TRUE")
            }
            self.updateLists()
        }
        .resume()
        
    }
    
    /// 리스트에 있는 플레이스 수정하기(주로 삭제하기)
    /// 뺄 어레이가 아니라 있는 어레이를 전달해야 업데이트 됨
    func editPlacesList(listID: String, placeIDs: [String], completionHandler: ((Bool) -> ())? = nil) {
        let body = ListBody(places: placeIDs)
        
        guard let request = authorizedRequest(method: "PATCH", api: "/me/lists/\(listID)", body: body) else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            print("Place list url error")
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode
            else {
                print("Error: \(response)")
                if let completionHandler = completionHandler {
                    completionHandler(false)
                }
                return
            }
            
            if let completionHandler = completionHandler {
                completionHandler(true)
            }
        }
        .resume()
        
    }

    /// 플레이스 리스트 받아오기. 퍼블리셔 타입.
    private func getPlaceLists(page: Int) -> AnyPublisher<[PlaceList], Error> {
        let queryItems = [
            URLQueryItem(name: "limit", value: "15"),
            URLQueryItem(name: "offset", value: "\(page)")
        ]
        
        guard let request = authorizedRequest(method: "GET", api: "/me/lists", queryItems: queryItems) else {
            return Fail(error: HTTPError.url).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
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
        guard let request = authorizedRequest(method: "POST", api: "/me/lists", body: body) else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            print("Place list url error")
            return
        }

        let session = URLSession.shared
        
        session.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode
            else {
                print("Place list response error: \(response as Any)")
                
                if let completionHandler = completionHandler {
                    completionHandler(false)
                }
                return
            }
            
            
            if let completionHandler = completionHandler {
                completionHandler(true)
            }
            
            self.updateLists()
        }
        .resume()
    }
    
    /// 플레이스 리스트 삭제
    func deletePlaceList(id: String, completionHandler: ((Bool) -> ())? = nil) {
        guard let request = authorizedRequest(method: "DELETE", api: "/me/lists/\(id)") else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode
            else {
                print("Place list response error: \(response as Any)")
                
                if let completionHandler = completionHandler {
                    completionHandler(false)
                }
                return
            }
            
            guard let index = (self.placeLists.firstIndex{ $0.identifier == id }) else {
                return
            }
            
            DispatchQueue.main.async {
                _ = withAnimation(.spring()) {
                    self.placeLists.remove(at: Int(index))
                }
            }
            
            if let completionHandler = completionHandler {
                completionHandler(true)
            }
        }
        .resume()
    }
    
    /// 플레이스 리스트 요소 수정
    func editListComponent(id: String, name: String? = nil, hex: String? = nil, completionHandler: ((Bool) -> ())? = nil) {
        guard let index = self.placeLists.firstIndex(where: { $0.identifier == id }) else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            return
        }
        
        let list = self.placeLists[index]
        var body = PlaceListPostBody(name: list.name, icon: list.icon, color: list.color, places: list.places)
        
        if let name = name {
            body.name = name
        }
        
        if let hex = hex {
            body.color = hex
        }
        
        guard let request = authorizedRequest(method: "PATCH", api: "me/lists/\(id)", body: body) else {
            if let completionHandler = completionHandler {
                completionHandler(false)
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode
            else {
                print("Place list response error: \(response as Any)")
                
                if let completionHandler = completionHandler {
                    completionHandler(false)
                }
                return
            }
            
            DispatchQueue.main.async {
                if let name = name {
                    self.placeLists[index].name = name
                }
                
                if let hex = hex {
                    self.placeLists[index].color = hex
                }
            }
            
            if let completionHandler = completionHandler {
                completionHandler(true)
            }
        }
        .resume()
        
    }
    
    /// 퍼블리셔로 리스트 업데이트 하는 루틴
    /// 페이지는 1페이지로 초기화
    func updateLists(page: Int = 1) {
        self.getPlaceLists(page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("[updateLists] Place list fetched")
                case .failure(let error):
                    print("Error while fetching place lists: \(error)")
                }
                
                self.subscriptions.removeAll()
            }, receiveValue: { data in
                if page == 1 {
                    self.placeLists = data
                } else {
                    self.placeLists.append(contentsOf: data)
                }
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
