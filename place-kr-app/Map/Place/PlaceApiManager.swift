//
//  PlaceApiManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI
import Combine

class PlaceApiManager {
    static func getPlace(_ place: String) -> AnyPublisher<PlaceResponse, Error> {
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
        guard let parsedPlace = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(parsedPlace)")
        else {
               return Fail(error: PlaceApiError.url).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(apiKey!)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PlaceResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

extension PlaceApiManager {
    enum PlaceApiError: Error, CustomStringConvertible {
        case keyLoad
        case url
        
        var description: String {
            switch self {
            case .keyLoad:
                return "Error occurs while loading api key"
            case .url:
                return "URL Error"
            }
        }
    }
}
