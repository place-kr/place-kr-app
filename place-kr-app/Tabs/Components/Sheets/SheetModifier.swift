//
//  AlertModifier.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

extension View {
    func showSheet<V>(sheet: V, show: Bool) -> some View where V: View {
        modifier(SheetModifier(sheet: sheet, show: show))
    }
}

struct SheetModifier<V>: ViewModifier where V: View {
    var sheet: V
    var show: Bool
    
    enum Style: CGFloat {
        case small
        case medium
        case large
        
        var position: CGFloat {
            switch self {
            case .small:
                return UIScreen.main.bounds.height - 300
            case .medium:
                return 400
            case .large:
                return 10
            }
        }
    }
    
    @State var offset: CGFloat = 0
    @State var currentStyle: Style = .small
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            if show {
                VStack {
                    HStack {
                        Spacer()
                        self.sheet
                        Spacer()
                    }
                    .padding(.top, 20)
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .zIndex(1)
                .background(
                    sheetShape
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y:-5)
                )
                .offset(y: offset + currentStyle.position)
                .transition(.move(edge: .bottom))
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            let offset = gesture.translation.height
                            let calcOffset = offset + currentStyle.position
                            if calcOffset > Style.large.position {
                                self.offset = offset
                            }
                        }
                        .onEnded({ value in
                            withAnimation(.spring()) {
                                self.offset = 0
                                if value.translation.height < -100 {
                                    currentStyle = .large
                                    
                                }  else {
                                    currentStyle = .small
                                }
                            }
                        })
                )
            }
            
            content
                .zIndex(0.5)
        }
    }
}

var sheetShape: some View {
    Rectangle()
        .fill(.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
}
