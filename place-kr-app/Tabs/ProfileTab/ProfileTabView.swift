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
    
    var body: some View {
        VStack {
            PageHeader(title: "마이페이지")
                .padding(.vertical, 17)
            
            List {
                NavigationLink(destination: {}) {
                    Text("공지사항")
                }
                
                NavigationLink(destination: {}) {
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
    }
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
    }
}
