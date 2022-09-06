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
    private let categories: [String] // TODO: BE AN ARRAY
    private let starButtonAction: (() -> Void)?
    private let shareButtonAction: (() -> Void)?
    private let imageUrl: URL?
    
    
    init(place: PlaceInfo, isFavorite: Bool, starAction: (() -> Void)? = nil, shareAction: (() -> Void)? = nil) {
        self.placeName = place.name
        self.subscripts = "님의 플레이스"
        self.countsDescription = "★ \(place.saves)명이 저장"
        self.imageUrl = place.imageUrl
        self.categories = place.category
        self.isFavorite = isFavorite
        
        self.starButtonAction = starAction
        self.shareButtonAction = shareAction
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 프로필 이미지
            WebImage(url: imageUrl)
                .placeholder(content: {
                    Image("listLogo")
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
                        .font(.basic.normal12)
                }
                Spacer()
                
                // 카테고리
                HStack {
                    ForEach(categories, id: \.self) { category in 
                        Text(category)
                            .encapsulate(mode: .light)
                    }
                }
            }
            .padding(10)
            .padding(.leading, 10)
            
            Spacer()
            // 스타, 공유 버튼
            VStack {
                HStack {
                    Button(action: {
                        guard let starButtonAction = starButtonAction else { return }                        
                        // 스타 버튼이 할 기능을 정함. 좋아요, 좋아요 취소 등이 들어갈 것임.
                        starButtonAction()
                    }) {
                        Image(isFavorite ? "placeAdded" : "placeNotAdded")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 27, height: 27)
                    }
                    
                    Button(action: {
                        guard let shareButtonAction = shareButtonAction else { return }
                        shareButtonAction()
                    }) {
                        Image("share")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 27, height: 27)
                    }
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
