//
//  ContentView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/18.
//

import SwiftUI
import CoreData
import Combine

// TODO: 위치 권한 핸들링
struct ContentView: View {
    @Environment(\.window) var window: UIWindow?
    @ObservedObject var loginManger = LoginManager()

    @State var isLoginSuccessed = false
    @State var isFirstRegistered = true // TODO: 언젠가 바꾸기
    
    var body: some View {
        // For debug - jump to map view
        if loginManger.status != .success {
            LogInView(success: $isLoginSuccessed)
                .environment(\.window, window)
                .environmentObject(loginManger)
        } else {
            if isFirstRegistered {
                OnboardingView(isClicked: $isFirstRegistered)
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
