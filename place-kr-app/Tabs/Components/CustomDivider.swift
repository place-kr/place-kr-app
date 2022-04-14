//
//  CustomDivider.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/14.
//

import Foundation
import SwiftUI

struct CustomDivider:  View {
    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.2))
            .frame(maxHeight: 0.5)
    }
}
