//
//  NewNameAlertView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

struct NewNameAlertView: View {
    @Binding var name: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("환영합니다")
                .font(.basic.largetitle)
                .padding(.top, 40)
            Text("name에서 활동할 이름을 입력해주세요")
                .font(.basic.subtitle)
                .padding(.bottom, 15)
            TextField("이곳에 이름을 입력해주세요", text: $name)
                .padding(10)
                .padding(.horizontal, 5)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("입력완료")
                }
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, width: 147, height: 40))
                .padding(.top, 25)
                .padding(.bottom, 20)
                
                Spacer()
            }
            
        }
        .alertStyle()
    }
}

struct NewNameAlertView_Previews: PreviewProvider {
    static var previews: some View {
        NewNameAlertView(name: .constant(""))
    }
}
