//
//  ProfileTabView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/28.
//

import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var loginManager: LoginManager
    
    @State var showLogoutAlert = false
    @State var showNameAlert = false
    @State var showWarning = false
    
    @State var name = ""
    
    var body: some View {
        VStack {
            PageHeader(title: "마이페이지")
                .padding(.vertical, 17)
            
            List {
                NavigationLink(destination: {}) {
                    Text("공지사항")
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        showNameAlert = true
                    }
                }) {
                    Text("개인정보 변경")
                }
                
                Button(action: { showLogoutAlert = true }) {
                    Text("로그아웃")
                }
                .alert(isPresented: $showLogoutAlert) {
                    Alert(title: Text("로그아웃 하시겠어요?"), primaryButton: .default(Text("Ok"), action: {
                        loginManager.logout()
                    }), secondaryButton: .cancel())
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle("")
            .environment(\.defaultMinListRowHeight, 70)
            .listStyle(.plain)
            .navigationBarItems(
                trailing:
                    NavigationLink(destination: {}) {
                        Image(systemName: "bell")
                    }
            )
        }
        .showAlert(show: $showNameAlert, alert: NewNameAlertView(name: $name, action: {
            // MARK: - 닉네임 변경 팝업
            AuthAPIManager.updateUserData(nickname: name) { result in
                switch result {
                case .success(()):
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.showNameAlert = false
                    }
                    break
                case .failure:
                    self.showWarning = true
                    break
                }
            }
        }))
    }
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
    }
}
