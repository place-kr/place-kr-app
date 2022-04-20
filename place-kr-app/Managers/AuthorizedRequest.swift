//
//  AuthorizedRequest.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/20.
//

import Foundation

func authorizedRequest(method: String, api: String) -> URLRequest? {
    guard let baseUrl = URL(string: "https://dev.place.tk/api/v1/" + api) else {
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

func authorizedRequest<T: Encodable>(method: String, api: String, body: T) -> URLRequest? {
    guard let baseUrl = URL(string: "https://dev.place.tk/api/v1/" + api) else {
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
