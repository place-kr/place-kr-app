//
//  SimplePlaceCardView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

struct SimplePlaceCardView: View {
    private let placeName: String
    private let subscripts: String
    private let buttonAction: (() -> Void)?
    private let image: UIImage
    
    init(_ name: String, subscripts: String, image: UIImage, action: (() -> Void)? = nil) {
        self.placeName = name
        self.subscripts = subscripts
        self.image = image
        self.buttonAction = action
    }
    
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.5))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(placeName)
                    .font(.system(size: 14, weight: .bold))
                Text(subscripts)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.leading, 14)
            
            Spacer()
            
            if let buttonAction = buttonAction {
                Button(action: { buttonAction() }) {
                        Text("Edit")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(RoundedButtonStyle(
                        bgColor: .gray.opacity(0.5),
                        textColor: .black,
                        isStroked: false,
                        width: 50,
                        height: 24)
                    )
            }
        }

    }
}

struct SimplePlaceCardView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePlaceCardView("", subscripts: "", image: UIImage())
    }
}
