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
    @State var isLoginSuccessed = false
    @State var isFirstRegistered = true // TODO: 언젠가 바꾸기
    
    var body: some View {
        // For debug - jump to map view
        TabView {
            MapView()
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Home")
                    }
                }
            
            ZStack {
                MyPlaceView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "star")
                    Text("My place")
                }
            }
            
            Text("Add")
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle")
                        Text("Add")
                    }
                }
            
            
            Text("Profile")
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                }
        }
        .accentColor(.black)
        .onAppear() {
            UITabBar.appearance().backgroundColor = .white
        }
        //        if !isLoginSuccessed {
        //            LogInView(success: $isLoginSuccessed)
        //                .environment(\.window, window)
        //        } else {
        //            if isFirstRegistered {
        //                OnboardingView(isClicked: $isFirstRegistered)
        //            } else {
        //                MapView()
        //            }
        //        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
