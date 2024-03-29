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
                .font(.basic.bold21)
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
                .font(.basic.bold21)
            Spacer()
        }
        HStack {
            Button(action: leadingAction) { // 폰트 고치지 마라
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
                .font(.basic.bold21)
            Spacer()
        }
        HStack {
            Spacer()

            Button(action: trailingAction) {
                trailing
                    .font(.basic.normal14)
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
                .font(.basic.bold21)
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
                        .font(.basic.normal14)
                        .foregroundColor(.black)
                }
            }
        }
    }
}


@ViewBuilder
func PageHeader<T: View>(title: String,
                                  leading: T, leadingAction: (() -> ())? = nil,
                                  firstTrailing: Image, firstAction: @escaping (() -> ()),
                                  secondeTrailing: Image, secondAction: @escaping (() -> ())) -> some View {
    
    ZStack {
        HStack(alignment: .center) {
            Spacer()
            Text(title)
                .font(.basic.bold21)
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
            
            HStack(spacing: 10) {
                Button(action: firstAction) {
                    firstTrailing
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
                
                Button(action: secondAction) {
                    secondeTrailing
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
            }
        }
    }
}

