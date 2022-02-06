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
    
    
    
//    /// Returning Userdata
//    var NaverLoginView: some View {
//        NaverVCRepresentable { userData in
//            if isUserRegistered(userData) == NaverUserData.userType.notRegistered {
//                UserProfile.create(userId: userData.id,
//                                   name: userData.name,
//                                   email: userData.email,
//                                   using: viewContext)
//            } else {
//                print("Already Registered")
//                print(userData.name)
//            }
//
//            success = true
//        }
//    }
    
//    private func isUserRegistered(_ user :NaverUserData) -> NaverUserData.userType {
//        // DB에 있는 유저인지 체크
//        // TODO: 웹에서 처리할 것인지?
//        let userID = user.id
//        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
//        let predicate = NSPredicate(format: "%K == %@", "userId", userID)
//        request.predicate = predicate
//
//        do {
//            let results = try viewContext.fetch(request)
//            print(results.count)
//            if results.isEmpty {
//                return .notRegistered
//            } else {
//                return .registered
//            }
//        } catch {
//            fatalError("Error while fetching user's profile")
//        }
//    }
}

