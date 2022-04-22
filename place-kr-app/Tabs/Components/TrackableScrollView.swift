//
//  TrackableScrollView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/21.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct TrackableScrollView<T: View>: View {
    @Binding var reachedBottom: Bool
    @State var offset: CGFloat = 0
    @State var wholeSize: CGSize = .zero
    @State var scrollViewSize: CGSize = .zero
        
    let content: T
    let action: () -> ()
    
    var body: some View {
        ChildSizeReader(size: $wholeSize) {
            ScrollView {
                ChildSizeReader(size: $scrollViewSize) {
                    content
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: ViewOffsetKey.self,
                                    value: -1 * proxy.frame(in: .named("scroll")).origin.y
                                )
                            }
                        )
                        .onPreferenceChange(
                            ViewOffsetKey.self,
                            perform: { value in
                                if value >= scrollViewSize.height - wholeSize.height - 100 && reachedBottom == false {
                                    self.reachedBottom = true
                                    action()
                                    print("User has reached the bottom of the ScrollView.")
                                }
                            }
                        )
                }
            }
            .coordinateSpace(name: "scroll")
        }
    }
    
    init(reachedBottom: Binding<Bool>, reachAction: @escaping () -> (), @ViewBuilder content: () -> T) {
        self._reachedBottom = reachedBottom
        self.action = reachAction
        self.content = content()
    }
}
