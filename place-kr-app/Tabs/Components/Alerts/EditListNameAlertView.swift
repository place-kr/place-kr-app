//
//  EditListNameAlert.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/13.
//

import SwiftUI

struct EditListNameAlertView: View {
    @State var clicked = false
    @Binding var name: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("리스트 이름 변경")
                .font(.basic.bold21)
                .padding(.top, 40)
            Text("변경할 리스트 이름을 입력해주세요")
                .font(.basic.light14)
                .padding(.bottom, 15)
            
            ThemedTextField($name, "변경할 리스트 명",
                            bgColor: .gray.opacity(0.3),
                            isStroked: false,
                            position: .trailing,
                            buttonImage: Image(""),
                            buttonColor: .gray.opacity(0.5),
                            action: {})
            HStack {
                Spacer()
                Button(action: {
                    action()
                    clicked = true
                }) {
                    Text("입력완료")
                }
                .disabled(name.isEmpty || clicked)
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, cornerRadius: 20,  isStroked: false, width: 147, height: 40))
                .padding(.top, 25)
                .padding(.bottom, 20)
                
                Spacer()
            }
            
        }
        .alertStyle()
    }
}
