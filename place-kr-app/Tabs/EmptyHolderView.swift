//
//  EmptyHolderView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/06/08.
//

import SwiftUI

struct EmptyHolderView: View {
    let title: String
    let message: String
    var buttonText: String? = nil
    var action: (() -> ())? = nil
    
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("addEmpty")
                .resizable()
                .frame(width: 65, height: 80)
                .padding(.bottom, 55)
            
            Text(title)
                .font(.basic.bold17)
                .padding(.bottom, 9)
            
            Text(message)
                .multilineTextAlignment(.center)
                .font(.basic.normal14)
            
            Spacer()
            
            if let buttonText = buttonText, let action = action {
                Button(action: action) {
                    HStack {
                        Spacer()
                        Text(buttonText)
                            .font(.basic.normal14)
                        Spacer()
                    }
                }
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, height: 52))
                .padding(.bottom, 20)
                .padding(.horizontal, 16)
            }
        }
    }
}
