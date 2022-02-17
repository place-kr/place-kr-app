//
//  Font + Extensions.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/17.
//

import SwiftUI

extension Font {
    struct Basic {
        let subtitle = Font.system(size: 12)
        let sub = Font.system(size: 14, weight: .bold)
        let cardtitle = Font.custom("Arial-BoldMT", size: 15)
        let description = Font.custom("Arial-BoldMT", size: 20)
        let light = Font.custom("ArialHebrew", size: 15)
    }
    
    struct Arial {
        let subtitle = Font.custom("Arial-BoldMT", size: 12)
        let cityname = Font.custom("ArialCEMTBlack-Regular", size: 25)
        let cardtitle = Font.custom("Arial-BoldMT", size: 15)
        let description = Font.custom("Arial-BoldMT", size: 20)
        let light = Font.custom("ArialHebrew", size: 15)
    }
    
    static let arial = Arial()
    static let basic = Basic()
}
