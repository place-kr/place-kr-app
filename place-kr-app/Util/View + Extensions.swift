//
//  View + Extensions.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/27.
//

import SwiftUI

fileprivate struct EncapsulateModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .bold))
            .padding(.vertical, 4)
            .padding(.horizontal, 9)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(red: 38/255, green: 38/255, blue: 38/255))
            )
            .foregroundColor(.white)
    }
}

struct CapsuledButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.black)
            .font(.system(size: 14))
            .frame(width: 52, height: 34)
    }
}

struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 16))
            .frame(width: 27, height: 27)
            .background(Circle()
                            .fill(Color.gray.opacity(0.3))
            )
    }
}

extension View {
    func expandToMax(width: CGFloat? = nil, height: CGFloat? = nil) -> some View{
        self.frame(minWidth: width == nil ? 0 : width,
                   maxWidth: width == nil ? .infinity: width,
                   minHeight: height == nil ? 0 : height,
                   maxHeight: height == nil ? .infinity : height,
                   alignment: .center)
    }
    
    func encapsulate() -> some View {
        modifier(EncapsulateModifier())
    }
}
