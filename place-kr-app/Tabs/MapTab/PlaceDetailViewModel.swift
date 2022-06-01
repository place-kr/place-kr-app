//
//  PlaceDetailViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/05/25.
//

import SwiftUI

class PlaceDetailViewModel: ObservableObject {
    typealias Review = ReviewResponse.Review
    
    @Published var placeInfo: PlaceInfo
    @Published var progress: Progress = .ready
    
    @Published var images: [Image] = [Image("dog"), Image("dog"), Image("dog")]
    @Published var reviews = [Review]()
    
    var nextPage: URL?
    
    /// id: Place ID
    func getReviews(id: String, nextUrl: URL? = nil, refresh: Bool = false) {
        self.progress = .inProcess
        
        var request: URLRequest? = nil
        if let url = nextUrl {
            request = PlaceSearchManager.authorizedRequest(url: "https" + String(Array(url.absoluteString)[4...]))
        } else {
            request = PlaceSearchManager.authorizedRequest(url: "https://dev.place.tk/api/v1/places/\(id)/reviews?limit=5")
        }
        
        guard var request = request else {
            self.progress = .failed
            return
        }

        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.progress = .failedWithError(error: error)
                }
                print(error)
            }
            
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                    default:
                        print(response)
                        self.progress = .failed
                    }
                }
            }
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(ReviewResponse.self, from: data)
                    print(decoded)
                    
                    DispatchQueue.main.async {
                        let reviews = decoded.results
                        
                        if refresh {
                            self.reviews = reviews
                        } else {
                            self.reviews.append(contentsOf: reviews)
                        }
                        
                        if let nextPageString = decoded.next {
                            guard let url = URL(string: nextPageString) else { return }
                            self.nextPage = url
                        }
                        
                        self.progress = .finished
                    }
                } catch(let error) {
                    print(error)
                    DispatchQueue.main.async {
                        self.progress = .failed
                    }
                }
            }
        }
        .resume()
    }
    /// id: Place id
    func deleteReview(id: String, completion: @escaping (Bool) -> Void) {
        self.progress = .inProcess

        guard let request = authorizedRequest(method: "DELETE", api: "/me/places/\(id)/review") else {
            completion(false)
            return
        }
        
        guard let userName = UserInfoManager.userName else {
            completion(false)
            return
        }
                    
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.progress = .failedWithError(error: error)
                    completion(false)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                        let index = self.reviews.firstIndex{ $0.reviewer.nickname == userName }! // TODO: Change to ID later
                        self.reviews.remove(at: index)
                        
                        completion(true)
                    default:
                        self.progress = .failed
                        
                        // 에러 바디 확인
                        if let data = data, let decoded = try? JSONDecoder().decode(ErrorBody.self, from: data)  {
                            print(decoded)
                        }
                        
                        completion(false)
                    }
                }
            }
        }
        .resume()
    }
    
    /// id: Place id, comment: 새 코멘트
    func postReview(id: String, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.progress = .inProcess
        
        guard let request = authorizedRequest(method: "POST", api: "/me/places/\(id)/review", body: ReviewBody(content: comment)) else {
            completion(.failure(URLError(.badURL)))
            return
        }
                    
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.progress = .failedWithError(error: error)
                    completion(.failure(URLError(.unknown)))
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                        completion(.success(()))
                    default:
                        print(response)
                        self.progress = .failed
                        
                        // 에러 바디 확인
                        if let data = data,
                            let decoded = try? JSONDecoder().decode(ReviewErrorBody.self, from: data) {
                            print(String(decoding: data, as: UTF8.self))
                            if decoded.details.ALREADY_REVIEWED != nil {
                                completion(.failure(URLError(.cancelled)))
                                return
                            }
                        }
                        
                        completion(.failure(URLError(.unknown)))
                    }
                }
            }
        }
        .resume()
    }
    
    /// id: Place id, comment: 수정할 코멘트
    func editReview(id: String, comment: String, completion: @escaping (Bool) -> Void) {
        self.progress = .inProcess

        let body = ReviewBody(content: comment)
        guard let request = authorizedRequest(method: "PUT", api: "/me/places/\(id)/review", body: body) else {
            completion(false)
            return
        }
        
        guard let userName = UserInfoManager.userName else {
            completion(false)
            return
        }
                    
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.progress = .failedWithError(error: error)
                    completion(false)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                        let index = self.reviews.firstIndex{ $0.reviewer.nickname == userName }! // TODO: Change to ID later
                        self.reviews.remove(at: index)
                        
                        completion(true)
                    default:
                        self.progress = .failed
                        
                        // 에러 바디 확인
                        if let data = data, let decoded = try? JSONDecoder().decode(ReviewErrorBody.self, from: data)  {
                            print(String(decoding: data, as: UTF8.self))
                            print(decoded)
                        }
                        
                        completion(false)
                    }
                }
            }
        }
        .resume()
    }
    
    init(info placeInfo: PlaceInfo) {
        self.placeInfo = placeInfo
        self.getReviews(id: placeInfo.id)
    }
}
