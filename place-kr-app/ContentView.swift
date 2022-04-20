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
 
    @State var showOnboarding = UserInfoManager.isRegistered ?? true
    
    var body: some View {
        // 로그인 안 되어있으면 로그인부터
        if loginManger.status != .loggedIn {
            LogInView()
                .environment(\.window, window)
                .environmentObject(loginManger)
        } else {
            if loginManger.isRegistered == false {
                OnboardingView(show: $showOnboarding)
            } else {
                TabsView()
                    .environmentObject(loginManger)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
