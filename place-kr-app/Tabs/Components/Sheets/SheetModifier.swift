//
//  AlertModifier.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

struct SheetModifier<V>: ViewModifier where V: View {
    var sheet: V
    
    @Binding var show: Bool
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
                .background(
                    sheetShape
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y:-5)
                )
                .edgesIgnoringSafeArea(.bottom)
                .offset(y: offset + currentStyle.position)
                .zIndex(1)
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
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.4)) {
                                self.offset = 0
                                let swiped = value.translation.height
                                // If dragged more than 100 upper side
                                if swiped < -100 {
                                    if currentStyle != .large {
                                        currentStyle = currentStyle.next()
                                    }
                                } else if (swiped > 200) {
                                    self.show = false
                                    currentStyle = .small
                                } else if (swiped > 10) {
                                    if currentStyle == .small {
                                        self.show = false
                                        currentStyle = .small
                                    } else {
                                        currentStyle = currentStyle.previous()
                                    }
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

extension SheetModifier {
    enum Style: CGFloat, CaseIterable {
        case small
//        case medium
        case large
        
        // https://stackoverflow.com/questions/51103795/how-to-get-next-case-of-enumi-e-write-a-circulating-method-in-swift-4-2
        func next() -> Self {
            let all = Self.allCases
            let idx = all.firstIndex(of: self)!
            let next = all.index(after: idx)
            return all[next == all.endIndex ? all.startIndex : next]
        }
        
        func previous() -> Self {
            let all = Self.allCases
            let idx = all.firstIndex(of: self)!
            let previous = all.index(before: idx)
            return all[previous < all.startIndex ? all.index(before: all.endIndex) : previous]
        }
        
        // Space from the top
        var position: CGFloat {
            switch self {
            case .small:
                return UIScreen.main.bounds.height - 250
//            case .medium:
//                return UIScreen.main.bounds.height / 2 - 100
            case .large:
                return 30
            }
        }
    }
    
    var sheetShape: some View {
        Rectangle()
            .fill(.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}
