//
//  NewNameAlertView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

class NewNameAlertViewModel: ObservableObject {
    @Published var progress: Progress = .ready
    
    
}

struct NewNameAlertView: View {
    @Binding var name: String
    @State var clicked = false
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("환영합니다")
                .font(.basic.bold21)
                .padding(.top, 40)
            Text("플레이스트에서 활동할 이름을 입력해주세요")
                .font(.basic.light14)
                .padding(.bottom, 15)
            ThemedTextField($name, "이곳에 이름을 입력해주세요",
                            bgColor: .gray.opacity(0.3),
                            isStroked: false,
                            position: .trailing,
                            buttonImage: Image(systemName: "dice.fill"),
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
                .disabled(clicked || name.isEmpty)
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, cornerRadius: 20, isStroked: false, width: 147, height: 40))
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
        NewNameAlertView(name: .constant(""), action: {})
    }
}
