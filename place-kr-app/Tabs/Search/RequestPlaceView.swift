//
//  RequestPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//

import SwiftUI

// MARK: TEMPORARY-

struct RequestPlaceView: View {
    @State var placeName = ""
    @State var address = ""
    @State var restAddress = ""
    
    var body: some View {
        VStack(spacing: 0) {
            headerTexts
                .padding(.vertical, 30)
            
            searchPlaceName
                .padding(.bottom, 20)
            
            searchAddr
            Spacer()
            registerButton
                .padding(.bottom, 15)
        }
        .padding(.horizontal, 15)
        .navigationBarTitle("플레이스 등록", displayMode: .inline)
    }
}

extension RequestPlaceView {
    var headerTexts: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("플레이스를 요청해보세요")
                .font(.basic.bold17)
            Text("플레이스를 등록해주시면 ---님의 이름으로 플레이스가\n추가되며, 등록 내용을 실시간으로 알려드릴게요!")
                .font(.basic.light14)
                .foregroundColor(.gray)
            
            // Filler
            HStack {
                Spacer()
            }
        }
    }
    
    var searchPlaceName: some View {
        VStack(alignment: .leading, spacing:  6) {
            Text("플레이스명")
                .font(.basic.light14)
                .foregroundColor(.gray)
            
            SearchBarView($placeName, "플레이스 이름을 입력해주세요", bgColor: .white, isStroked: true)
        }
    }
    
    var searchAddr: some View {
        VStack(alignment: .leading, spacing:  10) {
            Text("주소")
                .font(.basic.light14)
                .foregroundColor(.gray)
                .padding(.bottom, 5)
            
            Button(action: {}) {
                Text("주소 찾기")
                    .font(.system(size: 14))
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .gray.opacity(0.3), textColor: .black, isStroked: false, width: 90, height: 40))
            
            SearchBarView($address, "주소찾기를 통해 주소를 입력하세요", bgColor: .white, isStroked: true)
            SearchBarView($restAddress, "나머지 주소를 입력해주세요", bgColor: .white, isStroked: true)
        }
    }
    
    var registerButton: some View {
        Button(action: {}) {
            Text("플레이스 등록 요청하기")
                .font(.system(size: 14))
        }
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, height: 52))
    }
}

struct RequestPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        RequestPlaceView()
    }
}
