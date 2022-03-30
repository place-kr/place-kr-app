//
//  TabsView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/01.
//

import SwiftUI

struct TabsView: View {
    // TODO: 나중에 고칠 것 둘
    @State var showNewNameAlert = false
    @State var name = ""
    
    var body: some View {
        NavigationView {
            
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
            .showAlert(alert: NewNameAlertView(name: $name, action: {
                withAnimation(.easeInOut(duration: 0.2)) { self.showNewNameAlert = false }
            }),
                       show: showNewNameAlert)
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.showNewNameAlert = true
                    }
                }
                UITabBar.appearance().backgroundColor = .white
            }
        }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
