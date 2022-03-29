import Combine
import Foundation
import SwiftUI

import NaverThirdPartyLogin


enum NaverLoginError: Error, CustomStringConvertible {
    case expiredToken
    case invalidResponse
    
    var description: String {
        switch self {
        case .expiredToken:
            return "Token is invalid. It could be expired."
        case .invalidResponse:
            return "Invalid network response."
        }
    }
}

struct NaverUserInfo: Codable {
    let identifier: String
    let email: String
    let accessToken: String
    
    enum CodingKeys : String, CodingKey{
        case identifier
        case email
        case accessToken = "access_token"
    }
}

struct NaverVCRepresentable: UIViewControllerRepresentable {
    static var loginInstance: NaverThirdPartyLoginConnection? = nil
    
    // 로그아웃시도 사용되어서 static으로 선언
    let vc = NaverViewController()
    //    var callback: (NaverUserData) -> Void
    var callback: (Result<NaverUserInfo, NaverLoginError>) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(vc: vc, callback: callback)
    }
    
    class Coordinator: NSObject, NaverThirdPartyLoginConnectionDelegate {
        @Published var cancellable: AnyCancellable?
        var callback : (Result<NaverUserInfo, NaverLoginError>) -> Void
        
        init(vc: NaverViewController, callback: @escaping (Result<NaverUserInfo, NaverLoginError>) -> Void) {
            self.callback = callback
            super.init()
            vc.delegate = self
            
            NaverVCRepresentable.loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
            NaverVCRepresentable.loginInstance?.delegate = self
            NaverVCRepresentable.loginInstance?.requestThirdPartyLogin()
        }
        

        // 로그인에 성공한 경우 호출
        func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
            print("Success login")
            getInfo()
            //            self.callback(getAcessToken())
        }
        
        //  로그인된 상태(로그아웃이나 연동해제 하지않은 상태)에서 로그인 재시도
        func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
            print("Retry")
            //      loginInstance?.accessToken
            getInfo()
            //            self.callback(getAcessToken())
        }
        
        // 로그아웃
        func oauth20ConnectionDidFinishDeleteToken() {
            print("log out")
        }
        
        // 모든 error
        func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
            print("SS")
            print("[NaverVCRepresentable] \(error as Any)")
            print("error = \(error.localizedDescription)")
        }
        
        func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFinishAuthorizationWithResult receiveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
            print("[NaverVCRepresentable] \(receiveType as Any)")
        }
        
        func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailAuthorizationWithRecieveType receiveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
            print("[NaverVCRepresentable] \(receiveType as Any)")
        }
        
        
        private func getInfo() {
            guard
                let isValidAccessToken = NaverVCRepresentable.loginInstance?.isValidAccessTokenExpireTimeNow()
            else {
                // TODO: Handle error
                self.callback(.failure(.invalidResponse))
                return
            }
            
            if !isValidAccessToken { self.callback(.failure(.expiredToken)) }
            
            guard let tokenType = NaverVCRepresentable.loginInstance?.tokenType else {
                self.callback(.failure(.invalidResponse))
                return
            }
            guard let accessToken = NaverVCRepresentable.loginInstance?.accessToken else {
                self.callback(.failure(.invalidResponse))
                return
            }
            
            cancellable = try? NaverLogin(tokenType: tokenType, accessToken: accessToken)?
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        print("Naver login failed: \(error)")
                        self.callback(.failure(.invalidResponse))
                    case .finished:
                        print("Naver login successed")
                    }
                }, receiveValue: {
                    let userID = $0.response.id
                    let email = $0.response.email
                    let userInfo = NaverUserInfo(identifier: userID, email: email, accessToken: accessToken)
                    
                    self.callback(.success(userInfo))
                })
        }
        
        private func getAcessToken() -> Result<(String, String), NaverLoginError> {
            guard
                let isValidAccessToken = NaverVCRepresentable.loginInstance?.isValidAccessTokenExpireTimeNow()
            else {
                // TODO: Handle error
                return .failure(.invalidResponse)
            }
            
            if !isValidAccessToken { return .failure(.expiredToken) }
            
            guard let tokenType = NaverVCRepresentable.loginInstance?.tokenType else {
                return .failure(.invalidResponse)
            }
            guard let accessToken = NaverVCRepresentable.loginInstance?.accessToken else {
                return .failure(.invalidResponse)
            }
            
            return .success((tokenType, accessToken))
        }

        
        //        private func getInfo() {
        //            guard
        //                let isValidAccessToken = NaverVCRepresentable.loginInstance?.isValidAccessTokenExpireTimeNow()
        //            else {
        //                print("Naver login token expired")
        //                return
        //            }
        //
        //            if !isValidAccessToken { return }
        //
        //            guard let tokenType = NaverVCRepresentable.loginInstance?.tokenType else { return }
        //            guard let accessToken = NaverVCRepresentable.loginInstance?.accessToken else { return }
        //
        //            cancellable = try? NaverLogin(tokenType: tokenType, accessToken: accessToken)?
        //                .sink(receiveCompletion: { completion in
        //                    switch completion {
        //                    case let .failure(error):
        //                        print("Naver login failed")
        //                        fatalError("\(error)")
        //                    case .finished:
        //                        print("Naver login successed")
        //                    }
        //                }, receiveValue: { response_naver_login in
        //                    self.callback(response_naver_login.response)
        //                })
        //        }
    }
    
    typealias UIViewControllerType = UIViewController
}

class NaverViewController: UIViewController {
    weak var delegate: NaverThirdPartyLoginConnectionDelegate?
}
