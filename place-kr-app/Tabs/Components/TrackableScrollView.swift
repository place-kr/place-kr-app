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

struct ContentViewSizeKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ScrollViewSizeKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct TrackableScrollView<T: View>: View {
    @Binding var position: CGFloat
    @State var offset: CGFloat = 0
    @State var scrollSize: CGFloat = 0
    @State var contentHeight: CGFloat = 0
    let content: T
    
    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                let position = proxy.frame(in: .named("scroll")).maxY
                Color.clear.preference(key: ViewOffsetKey.self, value: position)
                
                content
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: ContentViewSizeKey.self, value: proxy.size.height)
                        }
                    )
            }
            .frame(height: self.contentHeight)
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollViewSizeKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(ViewOffsetKey.self) {
            self.position = $0
            print("offset \($0)")
        }
        .onPreferenceChange(ScrollViewSizeKey.self) {
            self.scrollSize = $0
            print("scroll \($0)")
        }
        .onPreferenceChange(ContentViewSizeKey.self) {
            self.contentHeight = $0
            print("height \($0)")
        }
        .coordinateSpace(name: "scroll")
    }
    
    init(position: Binding<CGFloat>, @ViewBuilder content: () -> T) {
        self._position = position
        self.content = content()
    }
}
