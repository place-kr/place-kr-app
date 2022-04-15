//
//  SimplePlaceCardView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

struct SimplePlaceCardView<T: View>: View {
    private let placeName: String
    private let placeColor: Color
    private let subscripts: String
    private let buttonLabel: T
    private let buttonAction: (() -> Void)?
    private let image: UIImage
    
    init(_ name: String, hex: String, subscripts: String, image: UIImage, buttonLabel: T, action: (() -> Void)? = nil) {
        self.placeName = name
        self.placeColor = colorFrom(hex: hex).color
        self.subscripts = subscripts
        self.image = image
        self.buttonLabel = buttonLabel
        self.buttonAction = action
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 프로필 이미지
            RoundedRectangle(cornerRadius: 10)
                .fill(self.placeColor)
                .frame(width: 50, height: 50)
            
            // 이름과 설명
            VStack(alignment: .leading) {
                Text(placeName)
                    .font(.system(size: 14, weight: .bold))
                Text(subscripts)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.leading, 14)
            
            Spacer()
            
            if let buttonAction = buttonAction {
                Button(action: buttonAction) {
                    buttonLabel
//                        .font(.system(size: 25))
//                        .frame(width: 25, height: 25)
                }
                .foregroundColor(.gray.opacity(0.8))
            }
        }
        
    }
}

//struct SimplePlaceCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        SimplePlaceCardView("", subscripts: "", image: UIImage())
//    }
//}
