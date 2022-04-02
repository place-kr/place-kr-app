//
//  PlaceApiManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI
import Combine

class PlaceSearchManager {
    /// Place 이름을 기반으로 주변 정보를 받아옵니다.(Kakao 기반)
    static func getKakaoPlacesByName(name: String) -> AnyPublisher<KakaoPlaceResponse, Error> {
        // Get path of APIKeys.plist
        guard let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist") else {
            return Fail(error: PlaceApiError.keyLoad as Error).eraseToAnyPublisher()
        }
        
        // Fetch my api key from APIKeys.plist
        var apiKey: String?
        do {
            let keyDictUrl = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: keyDictUrl)
            let keyDict = try PropertyListDecoder().decode([String: String].self, from: data)
            apiKey = keyDict["KakaoApiKey"]
        } catch  {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // Make URLSession.datapublisher which requests informations from the server
        let session = URLSession.shared
        guard let parsedPlace = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(parsedPlace)")
        else {
            return Fail(error: PlaceApiError.url).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(apiKey!)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: KakaoPlaceResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    /// Place 이름을 기반으로 주변 정보를 받아옵니다.(자체 서버)
    static func getPlacesByName(name: String) -> AnyPublisher<PlaceResponse, Error> {
        // Fetch my user token from UserDefault
        let token = UserInfoManager.userToken
        guard let token = token else {
            return Fail(error: PlaceApiError.fetch).eraseToAnyPublisher()
        }

        // TODO: 이거 검색 우선순위 어떻게..?
        let session = URLSession.shared // TODO: 쿼리부분 수정요청
        guard let url = URL(string: "")
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

    /// 맵 바운더리 기준으로 주변 정보를 받아옵니다
    static func getPlacesByBoundary(_ bounds: Boundary) -> AnyPublisher<PlaceResponse, Error> {
        // Fetch my user token from UserDefault
        let token = UserInfoManager.userToken
        guard let token = token else {
            return Fail(error: PlaceApiError.fetch).eraseToAnyPublisher()
        }

        // Make URLSession.datapublisher which requests informations from the server
        let session = URLSession.shared // TODO: 쿼리부분 수정요청
        guard let url = URL(string: "https://dev.place.tk/api/v1/places/search?query=\("_T_")&south_west_x=\(bounds.bottomleadingY)&south_west_y=\(bounds.bottomleadingX)&north_east_x=\(bounds.toptrailingY)&north_east_y=\(bounds.toptrailingX)")
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
