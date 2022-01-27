//
//  View + Extensions.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/27.
//

import SwiftUI

extension View {
    func expandToMax(width: CGFloat? = nil, height: CGFloat? = nil) -> some View{
        self.frame(minWidth: width == nil ? 0 : width,
                   maxWidth: width == nil ? .infinity: width,
                   minHeight: height == nil ? 0 : height,
                   maxHeight: height == nil ? .infinity : height,
                   alignment: .center)
    }
}
