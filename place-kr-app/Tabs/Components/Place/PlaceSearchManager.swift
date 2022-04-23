//
//  PlaceApiManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI
import Combine

/// 자체 플레이스트 리스트를 페치하는 역할을 합니다.
class PlaceSearchManager {
    static func authorizedRequest(url: String, name: String? = nil, page: Int? = nil) -> URLRequest? {
        // Fetch my user token from UserDefault
        let token = UserInfoManager.userToken
        guard let token = token else {
            return nil
        }
        
        guard var components = URLComponents(string: url) else {
            return nil
        }
        
        var queryItems = [URLQueryItem]()
        
        if let name = name {
            let name = URLQueryItem(name: "query", value: name)
            queryItems.append(name)
        }
        
        if let page = page {
            let page = URLQueryItem(name: "page", value: String(page))
            queryItems.append(page)
        }
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    /// Place 이름을 기반으로 주변 정보를 받아옵니다.(Kakao 기반)
    static func getKakaoPlacesByName(name: String, page: Int) -> AnyPublisher<[KakaoPlaceInfo], Error> {
        let queryItems = [
            URLQueryItem(name: "query", value: "\(name)"),
        ]
        
        guard let request = place_kr_app.authorizedRequest(method: "GET", api: "/places/kakao", queryItems: queryItems) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Response error: \(response)")
                    throw PlaceApiError.response
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    print("Response error: \(httpResponse)")
                    throw PlaceApiError.response
                }
                
                guard !data.isEmpty else {
                    print("Data error: \(data)")
                    throw PlaceApiError.data
                }
                
                return data
            }
            .decode(type: KakaoPlaceResponse.self, decoder: JSONDecoder())
            .map {
                if $0.meta.isEnd {
                    return []
                } else {
                    return $0.documents.map{ KakaoPlaceInfo(document: $0) }
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Place 이름을 기반으로 주변 정보를 받아옵니다.(자체 서버)
    static func getPlacesByName(name: String, page: Int) -> AnyPublisher<PlaceResponse, Error> {
        // Fetch my user token from UserDefault
        let token = UserInfoManager.userToken
        guard let token = token else {
            return Fail(error: PlaceApiError.fetch).eraseToAnyPublisher()
        }

        var components = URLComponents(string: "https://dev.place.tk/api/v1/places/search")
        let limit = URLQueryItem(name: "limit", value: "10")
        let offset = URLQueryItem(name: "offset", value: String(page * 10))
        let query = URLQueryItem(name: "query", value: name)
        
        components?.queryItems = [limit, offset, query]
        
        guard let url = components?.url else {
            return Fail(error: PlaceApiError.url).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        let decoder = JSONDecoder()
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Response error: \(response)")
                    throw PlaceApiError.response
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    print("Response error: \(httpResponse)")
                    throw PlaceApiError.response
                }
                
                guard !data.isEmpty else {
                    print("Data error: \(data)")
                    throw PlaceApiError.data
                }
                
                return data
            }
            .decode(type: PlaceResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// 맵 바운더리 기준으로 주변 정보를 받아옵니다
    static func getPlacesByBoundary(_ bounds: Boundary) -> AnyPublisher<PlaceResponse, Error> {
        // Fetch my user token from UserDefault
        let token = UserInfoManager.userToken
        guard let token = token else {
            return Fail(error: PlaceApiError.fetch).eraseToAnyPublisher()
        }

        // Make URLSession.datapublisher which requests informations from the server
        let session = URLSession.shared // TODO: 쿼리부분 수정요청
        guard let url = URL(string: "https://dev.place.tk/api/v1/places/search?south_west_x=\(bounds.bottomleadingY)&south_west_y=\(bounds.bottomleadingX)&north_east_x=\(bounds.toptrailingY)&north_east_y=\(bounds.toptrailingX)")
        else {
            return Fail(error: PlaceApiError.url).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let decoder = JSONDecoder()
        return session.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Response error: \(response)")
                    throw PlaceApiError.response
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    print("Response error: \(httpResponse)")
                    throw PlaceApiError.response
                }
                
                guard !data.isEmpty else {
                    print("Data error: \(data)")
                    throw PlaceApiError.data
                }
                
                return data
            }
            .decode(type: PlaceResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    /// Id로 장소 1개의 정보를 받아옵니다
    static func getPlacesByIdentifier(_ identifier: String) -> AnyPublisher<OnePlaceResponse, Error> {
        // Fetch my user token from UserDefault
        let token = UserInfoManager.userToken
        guard let token = token else {
            return Fail(error: PlaceApiError.fetch).eraseToAnyPublisher()
        }

        // Make URLSession.datapublisher which requests informations from the server
        let session = URLSession.shared
        guard let url = URL(string: "https://dev.place.tk/api/v1/places/\(identifier)")
        else {
            return Fail(error: PlaceApiError.url).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let decoder = JSONDecoder()
        return session.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Response error: \(response)")
                    throw PlaceApiError.response
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    print("Response error: \(httpResponse)")
                    throw PlaceApiError.response
                }
                
                guard !data.isEmpty else {
                    print("Data error: \(data)")
                    throw PlaceApiError.data
                }
                
                return data
            }
            .decode(type: OnePlaceResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// comma seperator로 구분된 아이디로 장소 여러개의 정보를 받아옵니다
    static func getMultiplePlacesByIdentifiers(_ identifiers: [String]) -> AnyPublisher<MultiplePlaceResponse, Error> {
        // Fetch my user token from UserDefault
        let token = UserInfoManager.userToken
        guard let token = token else {
            return Fail(error: PlaceApiError.fetch).eraseToAnyPublisher()
        }

        // Make URLSession.datapublisher which requests informations from the server
        let session = URLSession.shared
        let commaSeperatedIds = identifiers
            .reduce("") { previos, next in
                previos + "," + next
            }
            .dropFirst()
        
        guard let url = URL(string: "https://dev.place.tk/api/v1/places?identifiers=\(commaSeperatedIds)")
        else {
            return Fail(error: PlaceApiError.url).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let decoder = JSONDecoder()
        return session.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Response error: \(response)")
                    throw PlaceApiError.response
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    print("Response error: \(httpResponse)")
                    throw PlaceApiError.response
                }
                
                guard !data.isEmpty else {
                    print("Data error: \(data)")
                    throw PlaceApiError.data
                }
                
                
                
                return data
            }
            .decode(type: MultiplePlaceResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

}

extension PlaceSearchManager {
    enum PlaceApiError: Error, CustomStringConvertible {
        case keyLoad
        case url
        case fetch
        case response
        case data
        
        var description: String {
            switch self {
            case .keyLoad:
                return "Error occurs while loading api key"
            case .url:
                return "URL Error"
            case .fetch:
                return "Error while fetching user infos"
            case .response:
                return "Error in http responses"
            case .data:
                return "Empty data"
            }
        }
    }
    
    struct Boundary {
        
        let toptrailingX: Double
        let toptrailingY: Double
        let bottomleadingX: Double
        let bottomleadingY: Double
        
        init(_ toptrailingX: Double, _ toptrailingY: Double, _ bottomleadingX: Double, _ bottomleadingY: Double) {
            func formatter(_ number: Double) -> Double {
                return Double(String(format: "%.10f", number))!
            }
            
            self.toptrailingX = formatter(toptrailingX)
            self.toptrailingY = formatter(toptrailingY)
            self.bottomleadingX = formatter(bottomleadingX)
            self.bottomleadingY = formatter(bottomleadingY)
        }
    }
}
