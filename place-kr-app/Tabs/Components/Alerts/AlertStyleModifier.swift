//
//  AlertStyleModifier.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

extension View {
    func alertStyle() -> some View {
        modifier(AlertStyleModifier())
    }
}

struct AlertStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
            )
    }
}
