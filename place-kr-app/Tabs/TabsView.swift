//
//  TabsView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/01.
//

import SwiftUI

struct TabsView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Home")
                    }
                }
            
            MyPlaceView()
                .tabItem {
                    VStack {
                        Image(systemName: "star")
                        Text("My place")
                    }
                }
            
            AddTabView()
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle")
                        Text("Add")
                    }
                }
            
            ProfileTabView()
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
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
