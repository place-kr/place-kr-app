//
//  ProfileTabView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/28.
//

import SwiftUI

struct ProfileTabView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: {}) {
                    Text("공지사항")
                }
                NavigationLink(destination: {}) {
                    Text("내가 추가한 플레이스")
                }
                NavigationLink(destination: {}) {
                    Text("개인정보 변경")
                }
                NavigationLink(destination: {}) {
                    Text("로그아웃")
                }
            }
            .environment(\.defaultMinListRowHeight, 70)
            .listStyle(PlainListStyle())
            .navigationBarTitle("마이플레이스", displayMode: .inline)
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
