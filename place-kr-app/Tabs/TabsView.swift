//
//  TabsView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/01.
//

import SwiftUI

struct TabsView: View {
    @EnvironmentObject var loginManager: LoginManager
    @ObservedObject var listManager = ListManager()
    // TODO: 나중에 고칠 것 둘
    @State var showNewNameAlert = false
    @State var name = ""
    
    @State var selection: Tab = .map
    
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                MapView(selection: $selection)
                    .environmentObject(listManager)
                    .tabItem {
                        VStack {
                            Image(systemName: "magnifyingglass")
                            Text("Home")
                        }
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .tag(Tab.map)

                MyPlaceView(selection: $selection)
                    .environmentObject(listManager)
                    .tabItem {
                        VStack {
                            Image(systemName: "star")
                            Text("My place")
                        }
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .tag(Tab.myPlace)


                RegisterPlaceMainView()
                    .tabItem {
                        VStack {
                            Image(systemName: "plus.circle")
                            Text("Add")
                        }
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .tag(Tab.register)
                
                ProfileTabView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                    }
                    .environmentObject(loginManager)
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .tag(Tab.profile)

            }
            .navigationBarHidden(true)
            .accentColor(.black)
            .showAlert(show: $showNewNameAlert, alert: NewNameAlertView(name: $name, action: {
                withAnimation(.easeInOut(duration: 0.2)) { self.showNewNameAlert = false }
            }))
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.showNewNameAlert = (UserInfoManager.isRegistered == false)
                    }
                }
                UITabBar.appearance().backgroundColor = .white
            }
        }
    }
}

extension TabsView {
    enum Tab {
        case map
        case myPlace
        case register
        case profile
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
