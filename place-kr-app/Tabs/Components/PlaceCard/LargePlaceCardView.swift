//
//  PlaceCardView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/23.
//

import SwiftUI

struct LargePlaceCardView: View {
    var body: some View {
        HStack() {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.5))
                .frame(width: 94, height: 94)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    Text("미나미")
                        .bold()
                        .font(.system(size: 24))
                        .padding(.trailing, 6)
                    Group {
                        Image(systemName: "star.fill")
                        Text("3명이 저장")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
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
            
            VStack {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.gray)
                    }
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(CircleButtonStyle())
                Spacer()
            }
        }
    }
}

struct LargePlaceCardView_Previews: PreviewProvider {
    static var previews: some View {
        LargePlaceCardView()
    }
}
