//
//  CustomProgressView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/13.
//

import SDWebImageSwiftUI
import SwiftUI

var CustomProgressView: some View {
    return AnimatedImage(name: "ripple.gif", isAnimating: .constant(true))
        .resizable()
        .scaledToFit()
        .frame(width: 50, height: 50)
}


