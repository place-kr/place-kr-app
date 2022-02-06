//
//  NaverLoginViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/27.
//

import Foundation

class NaverLoginButtonViewModel: ObservableObject {
    private struct NaverLoginRequestResponse: Codable {
        let token: String
        
        func getDescription() {
            print("Token: \(self.token)")
        }
    }
    
    func completionHandler(_ result: Result<NaverUserInfo, NaverLoginError>) -> Bool{
        switch result {
        case .failure(let error):
            print(error)
        case .success(let userInfo):
            print("Successfully get token. Email:\(userInfo.email), Token:\(userInfo.accessToken)")
            
            let url = URL(string: "https://dev.place.tk/api/v1/auth/naver")!
            let encoder = JSONEncoder()
            guard let body = try? encoder.encode(userInfo) else {
                print("Error while encoding")
                // TODO: Error handle
                return false
            }
            
            self.sendPostRequest(to: url, body: body) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                }
            }
        }
        
        return true
    }
    
    private func sendPostRequest(to url: URL, body: Data, then handler: @escaping (Result<Data, Error>) -> Void) {
        let completionHandler = handler
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Peek into request body
        //        print(String(data: body, encoding: String.Encoding.utf8))
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Error while uploading")
                completionHandler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse, !((200...300).contains(response.statusCode)) {
                completionHandler(.failure(URLError.self as! Error))
                // Peek into response if error occurs
                print(response as Any)
            }

            guard let data = data else {
                completionHandler(.failure(URLError.self as! Error))
                print("Error in data")
                return
            }

            let decoder = JSONDecoder()
            guard let jsonData = try? decoder.decode(NaverLoginRequestResponse.self, from: data) else {
                print("Error while parsing")
                return
            }
            
            print(jsonData.getDescription())
        }
        task.resume()
    }
}
