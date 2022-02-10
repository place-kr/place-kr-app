//
//  ContentView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/18.
//

import SwiftUI
import CoreData
import Combine


struct ContentView: View {
    @Environment(\.window) var window: UIWindow?
    @State var isLoginSuccessed = false
    @State var isFirstRegistered = true // TODO: 언젠가 바꾸기
    
    var body: some View {
        if !isLoginSuccessed {
            LogInView(success: $isLoginSuccessed)
                .environment(\.window, window)
        } else {
            if isFirstRegistered {
                OnboardingView(isClicked: $isFirstRegistered)
            } else {
                MapView()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
