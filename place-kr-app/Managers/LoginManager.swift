//
//  LoginManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/01.
//

import Foundation

class LoginManager: ObservableObject {
    typealias AppleUserInfo = UserInfoManager.AppleUserInfo
    @Published var status: Status = .notLoggedIn
    @Published var isRegistered = false
    
    func logout() {
        UserInfoManager.logout()
        self.status = .notLoggedIn
    }
    
    /// API 서버에 네이버 소셜로그인에서 받은 토큰을 주고 앱에서 쓸 유저 토큰을 받아오는 동작을 하는 루틴입니다.
    func socialAuthResultHandler(_ result: Result<NaverUserInfo, NaverLoginError>) {
        switch result {
        case .failure(let error):
            print(error)
            self.status = .fail
        case .success(let userInfo):
            print("Successfully get token from API server. Email:\(userInfo.email), Token:\(userInfo.accessToken)")

            let url = URL(string: "https://dev.place.tk/api/v1/auth/naver")!
            let body = AuthAPIManager.NaverBody(
                identifier: userInfo.identifier,
                email: userInfo.email,
                accessToken: userInfo.accessToken
            )
            
            AuthAPIManager.sendPostRequest(to: url, body: body) { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.status = .fail
                    }
                    print(error)
                    break
                case .success(let result):
                    print("Registered: \(result.isRegistered)")
                    
                    /// UserDefault에 토큰 저장
                    UserInfoManager.saveUserToken(result.token)
                    UserInfoManager.registerStatus(result.isRegistered)
                    UserInfoManager.login()
                    
                    DispatchQueue.main.async {
                        self.isRegistered = result.isRegistered
                        self.status = .loggedIn
                    }
                    
                    break
                }
            }
        }
    }
    
    
    /// API 서버에 애플 소셜로그인에서 받은 토큰을 주고
    /// 앱에서 쓸 유저 토큰을 받아오는 루틴입니다.
    func socialAuthResultHandler(_ result: Result<AppleUserInfo, AppleLoginError>) {
        switch result {
        case .failure(let error):
            print("[LoginManager] Login failed: \(error)")
            self.status = .fail
        case .success(let userInfo):
            print("Successfully get token from API server. Email:\(userInfo.email), Token:\(userInfo.authCode)")
            
            let url = URL(string: "https://dev.place.tk/api/v1/auth/apple")!
            let body = AuthAPIManager.AppleBody(
                identifier: userInfo.id,
                email: userInfo.email,
                idToken: userInfo.idToken
            )

            // 토큰 전달
            AuthAPIManager.sendPostRequest(to: url, body: body) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print("[LoginManager] Login failed: \(error)")
                    DispatchQueue.main.async {
                        self.status = .fail
                    }
                    print(error)
                    break
                case .success(let result):
                    /// UserDefault에 토큰 저장
                    UserInfoManager.saveUserToken(result.token)
                    UserInfoManager.registerStatus(result.isRegistered)
                    UserInfoManager.login()
                    print("Successfully post apple login request")
                    
                    DispatchQueue.main.async {
                        self.isRegistered = result.isRegistered
                        self.status = .loggedIn
                    }
                        
                    break
                }
            }
        }
    }

    init() {
        guard let status = UserInfoManager.isLoggenIn else { return }
        self.status = status == true ? .loggedIn : .notLoggedIn
        
        guard let isRegistered = UserInfoManager.isRegistered else { return }
        self.isRegistered = isRegistered
    }
}

extension LoginManager {
    enum Status {
        case notLoggedIn
        case fail
        case loggedIn
        case inProgress
    }
}
