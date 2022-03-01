//
//  PlaceCardView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/23.
//

import SwiftUI

struct PlaceCardView: View {
    let bgColor: Color
    var placeInfo: PlaceInfo
    
    // TODO: Fix default data
    init(bgColor: Color,
         placeInfo: PlaceInfo = PlaceInfo(document: PlaceResponse.Document(
            id: UUID().uuidString,
            textAddress: "Dump",
            roadAddress: "Dump",
            name: "미나미",
            url: "Dump",
            x: String(111),
            y: String(111))
         ))
    {
        self.bgColor = bgColor
        self.placeInfo = placeInfo
    }
    
    
    var body: some View {
        ZStack {
            bgColor
            
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.5))
                    .frame(width: 94, height: 94)
                            
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("\(placeInfo.name)")
                            .bold()
                            .font(.system(size: 24))
                            .padding(.trailing, 6)
                        Group {
                            Image(systemName: "star.fill")
                            Text("3명이 저장")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(CircleButtonStyle(isSmall: true))
                    }
                    .padding(.bottom, 4)
                    
                    HStack(alignment: .center, spacing: 6) {
                        Group {
                            Image(systemName: "person.fill")
                            Text("포로리님의 플레이스")
                        }
                        .font(.system(size: 12))
                    }
                    .padding(.bottom, 20)
                    
                    HStack(spacing: 5) {
                        Text("일식")
                            .encapsulate()
                        Text("아늑해요")
                            .encapsulate()
                        Text("깔끔해요")
                            .encapsulate()
                    }
                }
                
                Spacer()
                
            }
        }
        
    }
}

struct PlaceCardView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceCardView(bgColor: Color(red: 246/255, green: 246/255, blue: 246/255))
    }
}
