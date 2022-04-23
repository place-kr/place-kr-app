//
//  UserDataManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/06.
//

import Foundation

/// User 데이터를 관리하는 클래스.
/// 관련된 정보는 UserDefault에 저장됨.
// TODO: Add Naver user register routine
class UserInfoManager {
    static let userInfoKey = "user"
    static let tokenKey = "token"
    static let loginKey = "login"
    static let registeredKey = "registered"
    static let searchHistoryKey = "searchHistory"
    
    /// 유저 정보를 저장함. 애플은 나중에 이메일을 알려주지 않으므로 잘 저장해놓아야 함.
    static func saveAppleUserInfo(_ info: AppleUserData) {
        let encoder = PropertyListEncoder()
        
        if let email = info.email,
           let name = info.name,
           let idToken = info.identityToken,
           let authCode = info.authCode {
            let id = info.identifier
            let userInfo = AppleUserInfo(id: id, email: email, name: name.description, idToken: idToken, authCode: authCode)
            
            do {
                let data = try encoder.encode(userInfo)
                UserDefaults.standard.set(data, forKey: userInfoKey)
                print(userInfo, data)
                print("Successfully saved apple user info")
            } catch {
                print("Error while saving apple user info")
                print(error)
            }
        } else {
            print("Error while saving apple user info")
            fatalError()
        }
    }
    
    /// 애플 유저 인포메이션을 로드
    static func loadUserInfo() -> AppleUserInfo? {
        let decoder = PropertyListDecoder()
        var userInfo: AppleUserInfo?
        do {
            if let data = UserDefaults.standard.object(forKey: userInfoKey) as? Data {
                userInfo = try decoder.decode(AppleUserInfo.self, from: data)
            } else {
                print("There's no apple user data")
            }
        } catch {
            print(error)
        }
        return userInfo
    }
    
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
    
    /// 저장기록 확인
    static var searchHistory: [String]? {
        let history = UserDefaults.standard.object(forKey: UserInfoManager.searchHistoryKey) as? [String]
        return history
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
