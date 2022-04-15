//
//  RequestCardView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/14.
//

import SwiftUI

struct RequestCardView: View {
    private let name: String
    private let address: String
    private let status: String
    
    var requestColor: Color {
        switch self.status {
        case "등록완료":
            return Color.blue
        case "등록실패":
            return Color.red
        case "접수중":
            return Color.gray
        default:
            return Color.black
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 플레이스 홀더
            Image("listLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(.trailing, 10)
            
            // 이름과 설명
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                
                // 장소 이름
                Text(name)
                    .font(.basic.bold14)
                
                // 장소 주소
                Text(address)
                    .font(.basic.normal12)
                
                Spacer()
            }
            
            Spacer()
            // 스타, 공유 버튼
            
            if let status = status {
                Text(status)
                    .font(.basic.bold12)
                    .foregroundColor(requestColor)
            }
            
        }
    }
    
    init(place: RegisterRequest) {
        self.name = place.name
        self.address = place.address
        self.status = place.parsedStatus
   }
}

