//
//  ContentView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/18.
//

import SwiftUI

// TODO: 위치 권한 핸들링
struct ContentView: View {
    @Environment(\.window) var window: UIWindow?
    @ObservedObject var loginManger = LoginManager()
    
    @State var showOnboarding = (UserInfoManager.isRegistered != true)
    @State var showLogin = (UserInfoManager.isLoggenIn != true)

    var body: some View {
//        TabsView()
        
        // 로그인 안 되어있으면 로그인부터
        if showLogin == true && loginManger.status != .success {
            LogInView()
                .environment(\.window, window)
                .environmentObject(loginManger)
        } else {
            if showOnboarding == true {
                OnboardingView(show: $showOnboarding)
            } else {
                TabsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
