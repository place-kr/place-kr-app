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
    
    /// API 서버에 네아로에서 받은 토큰을 주고 앱에서 쓸 유저 토큰을 받아오는 동작을 하는 루틴입니다.
    /// 성공 실패 여부를 Bool 타입으로 반환합니다.
    func completionHandler(_ result: Result<NaverUserInfo, NaverLoginError>) -> Bool {
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
