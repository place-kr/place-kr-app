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
            let body = AuthAPIManager.NaverBody(
                identifier: userInfo.identifier,
                email: userInfo.email,
                accessToken: userInfo.accessToken
            )
            
            AuthAPIManager.sendPostRequest(to: url, body: body) { result in
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
}
