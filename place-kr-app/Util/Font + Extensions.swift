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
        let light11 = Font.custom("NotoSansKR-Light", size: 11)
        
        /// size: 14, weight: light
        let light14 = Font.custom("NotoSansKR-Light", size: 14)
                
        /// size: 10, weight: normal
        let normal10 = Font.custom("NotoSansKR-Medium", size: 10)
        
        /// size: 12, weight: normal
        let normal12 = Font.custom("NotoSansKR-Medium", size: 12)
        
        /// size: 14, weight: normal
        let normal14 = Font.custom("NotoSansKR-Medium", size: 14)
        
        /// size: 15, weight: normal
        let normal15 = Font.custom("NotoSansKR-Medium", size: 15)
        
        /// size: 17, weight: normal
        let normal17 = Font.custom("NotoSansKR-Medium", size: 17)
        
        /// size: 20, weight: normal
        let normal20 = Font.custom("NotoSansKR-Medium", size: 20)
        
        func normal(_ size: CGFloat) -> Font {
            return Font.custom("NotoSansKR-Medium", size: size)
        }
        
        /// size: 10, weight: bold
        let bold10 = Font.custom("NotoSansKR-Bold", size: 10)
        
        /// size: 11, weight: bold
        let bold11 = Font.custom("NotoSansKR-Bold", size: 11)
        
        /// size: 12, weight: bold
        let bold12 = Font.custom("NotoSansKR-Bold", size: 12)

        /// size: 14, weight: bold
        let bold14 = Font.custom("NotoSansKR-Bold", size: 14)
        
        /// size: 17, weight: bold
        let bold17 = Font.custom("NotoSansKR-Bold", size: 17)
        
        /// size: 20, weight: bold
        let bold20 = Font.custom("NotoSansKR-Bold", size: 20)
        
        /// size: 21, weight: bold
        let bold21 = Font.custom("NotoSansKR-Bold", size: 21)
        
        /// size: 21, weight: bold
        let bold24 = Font.custom("NotoSansKR-Bold", size: 24)
        
        func bold(_ size: CGFloat) -> Font {
            return Font.custom("NotoSansKR-Bold", size: size)
        }
        
        /// size: 40, weight: bold
        let logo = Font.custom("NotoSansKR-Black", size: 40)
    }
    
    static let basic = Basic()
}
