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
    
    @State var showNewNameAlert = false
    @State var showWarning = false
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
            .showAlert(show: $showNewNameAlert, tapToDismiss: false, alert: NewNameAlertView(name: $name, action: {
                // MARK: - 닉네임 변경 팝업
                AuthAPIManager.updateUserData(nickname: name) { result in
                    switch result {
                    case .success(()):
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.showNewNameAlert = false
                        }
                        break
                    case .failure:
                        self.showWarning = true
                        break
                    }
                }
            }))
            .onAppear() {
                // MARK: 닉네임 체크
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print("@@", UserInfoManager.isRegistered)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.showNewNameAlert = (UserInfoManager.isRegistered == false)
                    }
                }
                UITabBar.appearance().backgroundColor = .white
            }
            .alert(isPresented: $showWarning) {
                basicSystemAlert
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
