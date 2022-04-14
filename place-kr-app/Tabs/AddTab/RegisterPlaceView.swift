//
//  RequestPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct RegisterPlaceView: View {
    @Environment(\.presentationMode) var presentation
    
    @State var placeName = ""
    @State var address = ""
    @State var restAddress = ""
    
    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: "플레이스 등록", leading: Image(systemName: "chevron.left"), leadingAction: {
                presentation.wrappedValue.dismiss()
            })
            .padding(.vertical)
            
            CustomDivider()
            
            headerTexts
                .padding(.vertical, 30)
            
            searchPlaceName
                .padding(.bottom, 20)
            
            searchAddr
                .padding(.bottom, 20)
            
            description
            
            Spacer()
            
            registerButton
                .padding(.bottom, 15)
        }
        .padding(.horizontal, 15)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

extension RegisterPlaceView {
    var headerTexts: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("플레이스를 요청해보세요")
                .font(.basic.bold17)
            Text("플레이스를 등록해주시면 ---님의 이름으로 플레이스가\n추가되며, 등록 내용을 실시간으로 알려드릴게요!")
                .font(.basic.light14)
                
            
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
                .padding(.bottom, 4)

            SearchBarView($placeName, "플레이스 이름을 입력해주세요", bgColor: .white, height: 40, isStroked: true)
        }
    }
    
    var searchAddr: some View {
        VStack(alignment: .leading, spacing:  10) {
            Text("주소")
                .font(.basic.light14)
                .padding(.bottom, 4)
            
            SearchBarView($address, "주소찾기를 통해 주소를 입력하세요", bgColor: .white, height: 40, isStroked: true)
            SearchBarView($restAddress, "나머지 주소를 입력해주세요", bgColor: .white, height: 40, isStroked: true)
            
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("플레이스 검색하기")
                        .font(.system(size: 14))
                }
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 40))
            
        }
    }
    
    var description: some View {
        VStack(alignment: .leading) {
            Text("설명 (옵션)")
                .font(.basic.light14)
                .padding(.bottom, 4)

            SearchBarView($address, "플레이스에 대해 설명해주세요", bgColor: .white, height: 40, isStroked: true)
        }
    }
    
    var registerButton: some View {
        Button(action: {}) {
            Text("플레이스 등록 요청하기")
                .font(.system(size: 14))
        }
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 52))
    }
}

struct RegisterPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPlaceView()
    }
}
