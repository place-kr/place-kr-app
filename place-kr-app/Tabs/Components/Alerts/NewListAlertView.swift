//
//  NewListAlertView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/29.
//

import SwiftUI

struct NewListAlertView: View {
    @Binding var name: String
    let action: () -> Void
    
    let colors: [Color] = [.gray]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("리스트 만들기")
                .font(.basic.largetitle)
                .padding(.top, 40)
            Text("리스트명을 입력하세요")
                .font(.basic.subtitle)
                .padding(.bottom, 15)
            ThemedTextField($name, "리스트명을 입력해주세요",
                            bgColor: .gray.opacity(0.3),
                            isStroked: false,
                            position: .trailing,
                            buttonName: "faceid",
                            buttonColor: .gray.opacity(0.5),
                            action: {})
            .padding(.bottom, 14)
            
            Text("리스트 컬러를 선택하세요")
                .padding(.bottom, 14)
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    Spacer()
                    ForEach(0..<5, id: \.self) { index in
                        let color = colors[0]
                        Circle().fill(color)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                HStack(spacing: 20) {
                    Spacer()
                    ForEach(0..<5, id: \.self) { index in
                        let color = colors[0]
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
            }
            
            HStack {
                Spacer()
                Button(action: action) {
                    Text("입력완료")
                }
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, width: 147, height: 40))
                .padding(.top, 25)
                .padding(.bottom, 20)
                
                Spacer()
            }
            
        }
        .frame(height: 380)
        .alertStyle()
    }
}

struct NewListAlertView_Preview: PreviewProvider {
    static var previews: some View {
        NewListAlertView(name: .constant(""), action: {})
    }
}
