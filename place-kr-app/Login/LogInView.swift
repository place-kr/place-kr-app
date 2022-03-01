//
//  LogInView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/22.
//

import SwiftUI
import CoreData
import Combine

struct LogInView: View {
    @Environment(\.window) var window: UIWindow?
    
    @Binding var success: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
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
            
            AppleLogInView(viewModel: AppleLoginViewModel(window: window), success: $success)
                .frame(height: 54)
                .environment(\.window, window)
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
        .padding(.horizontal, 27)
    }
    
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(success: .constant(false))
    }
}
