//
//  ContentView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/18.
//

import SwiftUI

struct ContentView: View {
    @State var showNaverLogin = false
    var body: some View {
        VStack {
            Text("Temporary")
            Button(action: { showNaverLogin = true }) {
                Text("Naver로 로그인")
            }
            AppleLogInButtonView()
            
            if showNaverLogin {
                NaverLoginView()
                    .frame(width: 0, height: 0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
