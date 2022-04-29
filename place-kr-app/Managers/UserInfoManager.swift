//
//  UserDataManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/06.
//

import Foundation

/// User 데이터를 관리하는 클래스.
/// 관련된 정보는 UserDefault에 저장됨.
/// 나중에 Realm을 고려해볼 것..
class UserInfoManager {
    static let userInfoKey = "user"
    static let tokenKey = "token"
    static let loginKey = "login"
    static let registeredKey = "registered"
    static let searchHistoryKey = "searchHistory"
    static let userNameKey = "userName"
    
    /// 유저 토큰을 유저 디폴트에 저장
    static func saveUserToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        print("Token is successfully saved: \(token)")
    }
    
    /// 로그인 - 유저 디폴트 값 변경
    static func login() {
        UserDefaults.standard.set(true, forKey: UserInfoManager.loginKey)
        print("Logged in")
    }
    
    /// 로그아웃 - 유저 디폴트 값 변경
    static func logout() {
        UserDefaults.standard.set(false, forKey: UserInfoManager.loginKey)
        print("Logged out")
    }
    
    /// 온보딩 여부 저장
    static func registerStatus(_ result: Bool) {
        UserDefaults.standard.set(result, forKey: UserInfoManager.registeredKey)
        print("@@ Registered: \(result)")
    }
    
    /// 검색기록 디스크에 저장
    static func saveSearchHistory(_ str: String) {
        if let history = self.searchHistory {
            // 키 있을 때
            let newValue = Array(Set(history + [str]))
            UserDefaults.standard.set(newValue, forKey: UserInfoManager.searchHistoryKey)
        } else {
            // 키 없을 때
            UserDefaults.standard.set([str], forKey: UserInfoManager.searchHistoryKey)
        }
    }
    
    /// 저장기록 확인
    static var searchHistory: [String]? {
        let history = UserDefaults.standard.object(forKey: UserInfoManager.searchHistoryKey) as? [String]
        return history
    }
    
    /// 검색기록 삭제
    static func deleteSearchHistory() {
        UserDefaults.standard.set([], forKey: UserInfoManager.searchHistoryKey)
    }
    
    /// 인증에 사용되는 유저 토큰(수정)
    static var userToken: String? {
        let token = UserDefaults.standard.string(forKey: UserInfoManager.tokenKey)
        print("Token is successfully loaded: \(token as Any)")
        return token 
    }
    
    /// 로그인 상태 확인
    static var isLoggenIn: Bool? {
        let loginStatus = UserDefaults.standard.object(forKey: UserInfoManager.loginKey) as? Bool
        return loginStatus
    }
    
    /// 등록된 유저(온보딩 완료)인지 확인
    static var isRegistered: Bool {
        let status = UserDefaults.standard.object(forKey: UserInfoManager.registeredKey) as? Bool
        return status == true
    }

    static func setUserName(to name: String) {
        UserDefaults.standard.set(name, forKey: UserInfoManager.userNameKey)
    }
    
    /// 유저 닉네임
    /// 항상 최신의 상태로 업데이트 되어야 함
    static var userName: String? {
        let name = UserDefaults.standard.object(forKey: UserInfoManager.userNameKey) as? String
        return name
    }
    
    // return User
    static func fetchUserInfoFromServer(completion: @escaping (User?) -> ()) {
        guard let request = authorizedRequest(method: "GET", api: "/me") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            print("User info fetched")
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                completion(nil)
                return
            }

            if !(200..<300 ~= response.statusCode) {
                print(response.statusCode, String(decoding: data, as: UTF8.self))
                completion(nil)
                return
            } else {
                guard let decoded = try? JSONDecoder().decode(User.self, from: data) else {
                    completion(nil)
                    return
                }
                
                completion(decoded)
            }
        }
        .resume()
    }
}

extension UserInfoManager {
    struct AppleUserInfo: Codable {
        let id: String
        let email: String?
        let name: String?
        let idToken: String
        let authCode: String
    }
}

struct User: Codable {
    let identifier: String
    let email: String
    let nickname: String
}
