//
//  LogInView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/22.
//

import SwiftUI
import CoreData
import Combine

class LoginManager: ObservableObject {
    @Published var status: status
    
    func socialAuthResultHandler(_ result: Result<NaverUserInfo, NaverLoginError>) {
        switch result {
        case .failure(let error):
            print(error)
            self.status = .fail
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
                    DispatchQueue.main.async {
                        self.status = .fail
                    }
                    print(error)
                case .success(let result):
                    DispatchQueue.main.async {
                        self.status = .success
                    }
                    
                    // TODO: result 저장하기
                    print(result)
                }
            }
        }
    }
    
    init() {
        self.status = .waiting
    }
}

extension LoginManager {
    enum status {
        case waiting
        case fail
        case success
        case inProgress
    }
}

struct LogInView: View {
    @Environment(\.window) var window: UIWindow?
    @ObservedObject var loginManger = LoginManager()
    @Binding var success: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                // TODO: 로딩 뷰 문의
                /// 앱 로고 디폴트 이미지
                RoundedRectangle(cornerRadius: 21)
                    .fill(.gray.opacity(0.5))
                    .frame(width: 125, height: 125)
                    .padding(.bottom, 40)
                
                Text("MY PLACE")
                    .font(.system(size: 37, weight: .black))
                    .padding(.bottom, 13)
                
                Text("나만의 플레이스를 만들어보세요!")
                    .font(.system(size: 17))
                
                Spacer()
                
                NaverLoginButtonView(success: $success)
                    .environmentObject(loginManger)
                
                AppleLogInView(viewModel: AppleLoginViewModel(window: window), success: $success)
                    .frame(height: 54)
                    .environment(\.window, window)
                    .environmentObject(loginManger)
                    .padding(.top, 14)
                    .padding(.bottom, 60)
                
                ZStack {
                    Text("소셜 로그인을 통해 로그인함으로써 개인정보처리방침¹과 이용약관²에 따라 계정을 연결하는 것에 동의합니다.")
                }
                .onTapGesture {
                    UIApplication.shared.open(URL(string: "https://www.naver.com")!)
                }
                .font(.system(size: 12))
                .foregroundColor(.gray)
            }
            .blur(radius: loginManger.status == .inProgress ? 5 : 0)
            
            if loginManger.status == .inProgress {
                ProgressView(style: UIActivityIndicatorView.Style.medium)
            }
        }
        
        .padding(.horizontal, 27)
    }
    
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(success: .constant(false))
    }
}
