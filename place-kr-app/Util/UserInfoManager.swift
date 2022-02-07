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
    static func saveAppleUserInfo(_ info: AppleUserData) {
        let encoder = PropertyListEncoder()
        
        if let email = info.email,
           let name = info.name,
           let idToken = info.identityToken,
           let authCode = info.authCode {
            let id = info.identifier
            let userInfo = AppleUserInfo(id: id, email: email, name: name.description, loginWith: .apple, idToken: idToken, authCode: authCode)
            
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
}

extension UserInfoManager {
    struct AppleUserInfo: Codable {
        let id: String
        let email: String
        let name: String
        let loginWith: Company
        let idToken: String
        let authCode: String
        
        enum Company: String, Codable {
            case naver
            case apple
            
            var description: String {
                switch self {
                case .naver:
                    return "naver"
                case .apple:
                    return "apple"
                }
            }
        }
    }
}