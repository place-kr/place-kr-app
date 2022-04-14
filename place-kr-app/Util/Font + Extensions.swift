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
        let light11 = Font.system(size: 11)
        
        /// size: 14, weight: light
        let light14 = Font.system(size: 14)
        
        /// size: 12, weight: normal
        let normal12 = Font.system(size: 12)
        
        /// size: 14, weight: bold
        let bold14 = Font.custom("Arial-BoldMT", size: 14)
        
        /// size: 15, weight: normal
        let normal15 = Font.custom("ArialHebrew", size: 15)
        
        /// size: 17, weight: bold
        let bold17 = Font.system(size: 17, weight: .bold)
        
        /// size: 21, weight: bold
        let bold21 = Font.system(size: 21, weight: .bold)
        
        /// size: 20, weight: bold
        let bold20 = Font.custom("Arial-BoldMT", size: 20)
    }
    
    static let basic = Basic()
}
