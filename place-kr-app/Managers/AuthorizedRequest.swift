//
//  AuthorizedRequest.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/20.
//

import Foundation

public func authorizedRequest(url: URL?) -> URLRequest? {
    guard let baseUrl = url else {
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

public func authorizedRequest(method: String, api: String) -> URLRequest? {
    guard let baseUrl = URL(string: "https://dev.place.tk/api/v1" + api) else {
        return nil
    }
    
    guard let token = UserInfoManager.userToken else {
        return nil
    }
    
     
    var request = URLRequest(url: baseUrl)
    request.httpMethod = method
    request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
}

    /// DO NOT ENCODE BODY
public func authorizedRequest<T: Encodable>(method: String, api: String, body: T) -> URLRequest?  {
    guard let baseUrl = URL(string: "https://dev.place.tk/api/v1" + api) else {
        return nil
    }
    
    guard let token = UserInfoManager.userToken else {
        return nil
    }
    
    guard let body = try? JSONEncoder().encode(body) else {
        return nil
    }
    
    var request = URLRequest(url: baseUrl)
    request.httpMethod = method
    request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = body
    
    return request
}

public func authorizedRequest(method: String, api: String, queryItems: [URLQueryItem]) -> URLRequest? {
    guard var urlComponent = URLComponents(string: "https://dev.place.tk/api/v1" + api) else {
        return nil
    }
    
    urlComponent.queryItems = queryItems

    guard let token = UserInfoManager.userToken else {
        return nil
    }
    
    guard let url = urlComponent.url else {
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
}
