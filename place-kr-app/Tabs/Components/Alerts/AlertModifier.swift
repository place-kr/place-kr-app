//
//  AlertModifier.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

extension View {
    func showAlert<V>(show: Binding<Bool>, alert: V) -> some View where V: View {
        modifier(AlertModifier(alert: alert, show: show))

    }
}

struct AlertModifier<V>: ViewModifier where V: View {
    var alert: V
    @Binding var show: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            if show {
                Color.gray.opacity(0.01)
                    .onTapGesture {
                        self.show = false
                    }
                    .zIndex(0.8)
                
                self.alert
                    .transition(.opacity)
                    .padding(.horizontal, 16)
                    .zIndex(1)
            }
            
            content
                .zIndex(0.5)
                .overlay(
                    Color.black.opacity(show ? 0.3 : 0)
                        .edgesIgnoringSafeArea(.all)
                )
        }
    }
}
