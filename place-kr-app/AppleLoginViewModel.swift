//
//  AppleLoginViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/05.
//

import SwiftUI
import CoreData
import AuthenticationServices



class AppleLoginViewModel: ObservableObject {
    @Published var appleSignInDelegates: AppleLoginDelegate! = nil
    
    var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    // MARK: Generate the delegate and assign it to the class’ property.
    func showAppleLogin(completionHandler: @escaping (Bool) -> (Void)) {
        let requests = ASAuthorizationAppleIDProvider().createRequest()
        requests.requestedScopes = [.fullName, .email]
        
        appleSignInDelegates = AppleLoginDelegate(window: window) { result in
            switch result {
            case .success(let userInfo):
                if let _ = userInfo.email, let _ = userInfo.name {
                    print("Newbie")
                    UserInfoManager.saveAppleUserInfo(userInfo)
                    // TODO: 서버에 뉴비 등록
                } else {
                    print("Already registered.") // TODO: 중복 등록?
                    guard let userInfo = UserInfoManager.loadUserInfo() else {
                        return
                    }
                    
                    // Post request
                    let url = URL(string: "https://dev.place.tk/api/v1/auth/apple")!
                    let body = AuthAPIManager.AppleBody(
                        identifier: userInfo.id,
                        email: userInfo.email,
                        idToken: userInfo.idToken
                    )

                    AuthAPIManager.sendPostRequest(to: url, body: body) { result in
                        switch result {
                            // TODO: 실패처리하기
                        default:
                            print("Successfully post apple login request")
                        }
                    }
                }
                completionHandler(true)
                break
            case .failure(let error):
                print("Error while preparing Apple login")
                completionHandler(false)
                print(error as Error)
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
