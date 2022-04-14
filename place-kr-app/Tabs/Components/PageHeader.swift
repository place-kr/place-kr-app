//
//  PageHeader.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/30.
//

import SwiftUI

@ViewBuilder
func PageHeader(title: String) -> some View  {
    
    ZStack {
        HStack(alignment: .center) {
            Spacer()
            Text(title)
                .bold()
                .font(.system(size: 21))
            Spacer()
        }
    }
}

@ViewBuilder
func PageHeader<T: View>(title: String, leading: T, leadingAction: @escaping (() -> ())) -> some View  {
    
    ZStack {
        HStack(alignment: .center) {
            Spacer()
            Text(title)
                .bold()
                .font(.system(size: 21))
            Spacer()
        }
        HStack {
            Button(action: leadingAction) {
                leading
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
    }
}

@ViewBuilder
func PageHeader<T: View>(title: String, trailing: T, trailingAction: @escaping (() -> ())) -> some View  {
    
    ZStack {
        HStack(alignment: .center) {
            Spacer()
            Text(title)
                .bold()
                .font(.system(size: 21))
            Spacer()
        }
        HStack {
            Spacer()

            Button(action: trailingAction) {
                trailing
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
        }
    }
}

@ViewBuilder
func PageHeader<T: View, S: View>(title: String,
                leading: T, leadingAction: (() -> ())? = nil,
                trailing: S, trailingAction: (() -> ())? = nil ) -> some View  {
    
    ZStack {
        HStack(alignment: .center) {
            Spacer()
            Text(title)
                .bold()
                .font(.system(size: 21))
            Spacer()
        }
        HStack {
            if let leading = leading, let action = leadingAction {
                Button(action: action) {
                    leading
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
            
            if let trailing = trailing, let action = trailingAction {
                Button(action: action) {
                    trailing
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
        }
    }
}

