import Combine
import Foundation
import SwiftUI

import NaverThirdPartyLogin

struct NaverVCRepresentable: UIViewControllerRepresentable {
    static var loginInstance: NaverThirdPartyLoginConnection? = nil
    
    // 로그아웃시도 사용되어서 static으로 선언
    let vc = NaverViewController()
    var callback: (NaverLoginResponse) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(vc: vc, callback: callback)
    }
    
    class Coordinator: NSObject, NaverThirdPartyLoginConnectionDelegate {
        @Published var cancellable: AnyCancellable?
        var callback: (NaverLoginResponse) -> Void
        
        init(vc: NaverViewController, callback: @escaping (NaverLoginResponse) -> Void) {
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
        }
        
        //  로그인된 상태(로그아웃이나 연동해제 하지않은 상태)에서 로그인 재시도
        func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
            //      loginInstance?.accessToken
            getInfo()
        }
        
        // 로그아웃
        func oauth20ConnectionDidFinishDeleteToken() {
            print("log out")
        }
        
        // 모든 error
        func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
            print("error = \(error.localizedDescription)")
        }
        
        func getInfo() {
            guard let isValidAccessToken = NaverVCRepresentable.loginInstance?.isValidAccessTokenExpireTimeNow() else {
                print("Naver login token expired")
                return
            }
            
            if !isValidAccessToken { return }
            
            guard let tokenType = NaverVCRepresentable.loginInstance?.tokenType else { return }
            guard let accessToken = NaverVCRepresentable.loginInstance?.accessToken else { return }
            
            cancellable = try? NaverLogin(tokenType: tokenType, accessToken: accessToken)?
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        print("Naver login failed")
                        print(error)
                    case .finished:
                        print("DONE - postUserPublisher")
                    }
                }, receiveValue: { response_naver_login in
                    print("네이버 로그인 이메일 \(response_naver_login.response)")
                    self.callback(response_naver_login.response)
                })
        }
    }
    
    typealias UIViewControllerType = UIViewController
}

class NaverViewController: UIViewController {
    weak var delegate: NaverThirdPartyLoginConnectionDelegate?
}
