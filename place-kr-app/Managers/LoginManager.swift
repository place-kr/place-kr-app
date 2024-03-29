//
//  LoginManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/01.
//

import Foundation

/// 유저의 로그인, 상태에 대해 관리하는 클래스
/// 스태틱 사용하지 않으며 최상위에서 환경오브젝트로 작동
class LoginManager: ObservableObject {
    typealias AppleUserInfo = UserInfoManager.AppleUserInfo
    @Published var status: Status = .notLoggedIn
    @Published var isRegistered = false
    
    func logout() {
        UserInfoManager.logout()
        self.status = .notLoggedIn
    }
    
    /// API 서버에 네이버 소셜로그인에서 받은 토큰을 주고 앱에서 쓸 유저 토큰을 받아오는 동작을 하는 루틴입니다.
    /// 로그인은 여기서만 일단 관리하면 됨
    func socialAuthResultHandler(_ result: Result<NaverUserInfo, NaverLoginError>) {
        switch result {
        case .failure(let error):
            print(error)
            self.status = .fail
        case .success(let userInfo):
            print("Successfully get token from OAuth server. Email:\(userInfo.email), Token:\(userInfo.accessToken)")

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
                    print("@@ Registered required: \(result.isRegisterRequired)")
                    
                    /// UserDefault에 토큰 저장
                    UserInfoManager.saveUserToken(result.token)
                    UserInfoManager.login()
                    
                    DispatchQueue.main.async {
                        self.status = .loggedIn
                        self.isRegistered = !result.isRegisterRequired
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
            print("Successfully get token from Apple server. Token:\(userInfo.authCode)")
            
            let url = URL(string: "https://dev.place.tk/api/v1/auth/apple")!
            let body = AuthAPIManager.AppleBody(
                identifier: userInfo.id,
                authorizationCode: userInfo.authCode,
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
                    UserInfoManager.login()
                    print("Successfully post apple login request")
                    
                    DispatchQueue.main.async {
                        self.isRegistered = !result.isRegisterRequired
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
        self.isRegistered = UserInfoManager.isRegistered
        
        // TODO: Refactor this
        UserInfoManager.fetchUserInfoFromServer { user in
            guard let user = user else {
                print("Something wrong while fetching user")
                return
            }
            
            UserInfoManager.setUserName(to: user.nickname)
        }
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
