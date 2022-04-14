//
//  TabsView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/01.
//

import SwiftUI

struct TabsView: View {
    @ObservedObject var listManager = ListManager()
    // TODO: 나중에 고칠 것 둘
    @State var showNewNameAlert = false
    @State var name = ""
    
    @State var selection: Tab = .map
    
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                MapView()
                    .environmentObject(listManager)
                    .tabItem {
                        VStack {
                            Image(systemName: "magnifyingglass")
                            Text("Home")
                        }
                    }
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
                    .navigationBarHidden(true)
                    .tag(Tab.myPlace)


                RegisterPlaceMainView()
                    .tabItem {
                        VStack {
                            Image(systemName: "plus.circle")
                            Text("Add")
                        }
                    }
                    .navigationBarHidden(true)
                    .tag(Tab.register)
                
                ProfileTabView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                    }
                    .tag(Tab.profile)

            }
            .accentColor(.black)
            .showAlert(show: showNewNameAlert, alert: NewNameAlertView(name: $name, action: {
                withAnimation(.easeInOut(duration: 0.2)) { self.showNewNameAlert = false }
            }))
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
