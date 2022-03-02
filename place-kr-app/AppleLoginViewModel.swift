//
//  AppleLoginViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/05.
//

import SwiftUI
import CoreData
import AuthenticationServices


// TODO: 애플로그인 중간 취소시 화면 전환 안됨. 
class AppleLoginViewModel: ObservableObject {
    typealias AppleUserInfo = UserInfoManager.AppleUserInfo
    @Published var appleSignInDelegates: AppleLoginDelegate! = nil
    
    var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    // MARK: Generate the delegate and assign it to the class’ property.
    func showAppleLogin(completionHandler: @escaping (Result<AppleUserInfo, AppleLoginError>) -> (Void)) {
        let requests = ASAuthorizationAppleIDProvider().createRequest()
        requests.requestedScopes = [.fullName, .email]
        
        appleSignInDelegates = AppleLoginDelegate(window: window) { result in
            switch result {
            case .failure(let error):
                print("Error while preparing Apple login")
                completionHandler(.failure(.invalidResponse))
                print(error as Error)
                break
            case .success(let userData):
                if let _ = userData.email, let _ = userData.name {
                    /// 신규 등록 사용자의 경우 이메일과 이름을 제공
                    print("Newbie")
                    UserInfoManager.saveAppleUserInfo(userData)
                    
                    guard let userInfo = UserInfoManager.loadUserInfo() else {
                        print("Error while fetching user data from UserDefault. The problem might have occurred during saving routine")
                        completionHandler(.failure(.fetch))
                        return
                    }
                    
                    completionHandler(.success(userInfo))
                    // TODO: 서버에 뉴비 등록
                } else {
                    /// 기존 등록 사용자의 경우 Identifier만 제공
                    print("Already registered.") // TODO: 중복 등록?
                    guard let userInfo = UserInfoManager.loadUserInfo() else {
                        return
                    }
                    completionHandler(.success(userInfo))
                }
                break
            }
        }
        
        let controller = ASAuthorizationController(authorizationRequests: [requests])
        controller.delegate = appleSignInDelegates
        controller.presentationContextProvider = appleSignInDelegates
        controller.performRequests()
    }
}

extension AppleLoginViewModel {
    private struct AppleLoginRequestResponse: Codable {
        let token: String
        
        func getDescription() {
            print("Token: \(self.token)")
        }
    }
}
