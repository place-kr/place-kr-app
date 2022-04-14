//
//  LightCardView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/05.
//

import SwiftUI
import SDWebImageSwiftUI

struct LightCardView: View {
    private let isFavorite: Bool
    private let placeName: String
    private let subscripts: String
    private let countsDescription: String
    private let categories: String // TODO: BE AN ARRAY
    private let buttonAction: (() -> Void)?
    private let imageUrl: URL?
    
    
    init(place: PlaceInfo, isFavorite: Bool, action: (() -> Void)? = nil) {
        self.placeName = place.name
        self.subscripts = "ㅇㅇㅇ님의 플레이스"
        self.countsDescription = "★ \(place.saves)명이 저장"
        self.imageUrl = place.imageUrl
        self.categories = place.category
        self.isFavorite = isFavorite
        self.buttonAction = action
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 프로필 이미지
            WebImage(url: imageUrl)
                .placeholder(content: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.gray)
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .cornerRadius(10)
            
            // 이름과 설명
            VStack(alignment: .leading, spacing: 6) {
                // 장소, 스타
                HStack {
                    Text(placeName)
                        .font(.basic.bold14)
                    Text(countsDescription)
                        .font(.basic.normal12)
                }
                
                // ~~ 님의 플레이스
                HStack(spacing : 4) {
                    Image(systemName: "person.fill")
                    Text(subscripts)
                        .font(.system(size: 12, weight: .medium))
                }
                Spacer()
                
                // 카테고리
                HStack {
                    Text(categories)
                        .encapsulate(mode: .light)
                }
            }
            .padding(10)
            .padding(.leading, 10)
            
            Spacer()
            // 스타, 공유 버튼
            VStack {
                HStack {
                    StarButtonShape(27, fgColor: .gray, bgColor: .gray.opacity(0.3))
                    ShareButtonShape(27, fgColor: .gray, bgColor: .gray.opacity(0.3))
                }
                Spacer()
            }
        }
        .frame(height: 80)
    }
}

//struct LightCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LightCardView()
//    }
//}
