//
//  RegisterPlaceMainView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/14.
//

import SwiftUI

struct RegisterPlaceMainView: View {
    @State var navigateToRegister = false
    
    var body: some View {
        VStack {
            // 네비게이트 대상
            Navigators
            
            PageHeader(title: "플레이스 등록", trailing: Text("등록하기"), trailingAction: {})
                .padding(.vertical, 17)
            
            CustomDivider()
            
            Spacer()
            
            Image("addEmpty")
                .resizable()
                .frame(width: 65, height: 80)
                .padding(.bottom, 55)
            
            Text("직접 플레이스를 등록해보세요")
                .font(.basic.bold17)
                .padding(.bottom, 9)
            
            Text("여러분의 플레이스 등록 참여로\n 더욱 풍성한 플레이스를 만들어주세요")
                .multilineTextAlignment(.center)
                .font(.basic.normal14)

            Spacer()
            
            Button(action: { navigateToRegister = true }) {
                Text("플레이스 등록하기")
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isSpanned: true, height: 52))
            .padding(.bottom, 20)
        }
        .navigationBarTitle("")
        .padding(.horizontal, 15)
    }
}

extension RegisterPlaceMainView {
    var Navigators: some View {
        NavigationLink(destination: RegisterPlaceView(), isActive: $navigateToRegister) {
            EmptyView()
        }
    }
}

struct RegisterPlaceMainView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPlaceMainView()
    }
}
