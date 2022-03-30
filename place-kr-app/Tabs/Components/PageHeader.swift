//
//  PageHeader.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/30.
//

import SwiftUI

@ViewBuilder
func PageHeader(title: String,
                leading: String? = nil, leadingAction leadingAction: (() -> ())? = nil,
                trailing: String? = nil, trailingAction trailingAction: (() -> ())? = nil ) -> some View  {
    ZStack {
        HStack(alignment: .center) {
            Spacer()
            Text(title)
                .bold()
                .font(.system(size: 21))
            Spacer()
        }
        HStack {
            if let text = leading, let action = leadingAction {
                Button(action: action) {
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
            
            if let text = trailing, let action = trailingAction {
                Button(action: action) {
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
        }
    }

    
}
