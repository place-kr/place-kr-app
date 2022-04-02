//
//  Font + Extensions.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/17.
//

import SwiftUI

extension Font {
    struct Basic {
        /// size: 11, weight: light
        let caption = Font.system(size: 11)
        
        /// size: 12, weight: normal
        let normal = Font.system(size: 12)

        /// size: 14, weight: light
        let subtitle = Font.system(size: 14)
        
        /// size: 17, weight: bold
        let title = Font.system(size: 17, weight: .bold)
        
        /// size: 17, weight: bold
        let largetitle = Font.system(size: 21, weight: .bold)

        
        let cardtitle = Font.custom("Arial-BoldMT", size: 15)
        let description = Font.custom("Arial-BoldMT", size: 20)
        let light = Font.custom("ArialHebrew", size: 15)
    }
    
    static let basic = Basic()
}
