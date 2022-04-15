//
//  LogInView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/22.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    let imageNames = ["mainIcon1", "mainIcon2", "mainIcon3", "mainIcon4", "mainIcon5", "mainIcon6"]
}

// TODO: 자동로그인
struct LogInView: View {
    @EnvironmentObject var loginManager: LoginManager
    @Environment(\.window) var window: UIWindow?
    @Binding var success: Bool
    
    @ObservedObject var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                // TODO: 인디케이터
                
                /// 앱 로고 디폴트 이미지
                HStack {
                    Spacer()
                    ZStack(alignment: .bottomLeading) {
                        Image("mainLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 84)
                            .padding(.bottom, 40)
                            .zIndex(1)
                        
                        HStack(spacing: 0) {
                            ForEach(viewModel.imageNames, id: \.self) { name in
                                Image(name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("PLAIST")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.bottom, 14)
                    
                    Text("플레이스트에서 나만의 플레이스를\n 만들고, 즐겨보세요!")
                        .font(.system(size: 17))
                }
                
                Spacer()
                
                NaverLoginButtonView()
                    .environmentObject(loginManager)
                
                // TODO: 로그인 취소 후 블러 유지되는 문제 해결
                AppleLogInView(viewModel: AppleLoginViewModel(window: window))
                    .frame(height: 54)
                    .environment(\.window, window)
                    .environmentObject(loginManager)
                    .padding(.top, 14)
                    .padding(.bottom, 60)
                
                ZStack {
                    // TODO: 링크 연계
                    Text("소셜 로그인을 통해 로그인함으로써 개인정보처리방침¹과 이용약관²에 따라 계정을 연결하는 것에 동의합니다.")
                }
                .onTapGesture {
                    UIApplication.shared.open(URL(string: "https://www.naver.com")!)
                }
                .font(.system(size: 12))
                .foregroundColor(.gray)
            }
            
            if loginManager.status == .inProgress {
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
