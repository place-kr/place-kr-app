//
//  RequestPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//

import SwiftUI
import Combine

struct RegisterPlaceView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var viewModel: RegisterPlaceMainViewModel
    
    @State var showAddressSearch = false
    
    @State var placeName = ""
    @State var address = ""
    @State var restAddress = ""
    @State var descriptionText = ""
    @State var coord = ("0.0", "0.0")
    
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
        .overlay(
            Group{ if viewModel.progress == .inProcess { ProgressView(style: .medium) }}
        )
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

extension RegisterPlaceView {
    // 설명
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
    
    // 플레이스 이름 입력 파트
    var searchPlaceName: some View {
        VStack(alignment: .leading, spacing:  6) {
            Text("플레이스명")
                .font(.basic.light14)
                .padding(.bottom, 4)

            SearchBarView($placeName, "플레이스 이름을 입력해주세요", bgColor: .white, height: 40, isStroked: true)
        }
    }
    
    // 주소찾기 텍스트 필드 파트
    var searchAddr: some View {
        VStack(alignment: .leading, spacing:  10) {
            Text("주소")
                .font(.basic.light14)
                .padding(.bottom, 4)
            
            SearchBarView($address, "주소찾기를 통해 주소를 입력하세요", bgColor: .white, height: 40, isStroked: true)
                .disabled(true)
            SearchBarView($restAddress, "나머지 주소를 입력해주세요", bgColor: .white, height: 40, isStroked: true)
            
            
            Button(action: { showAddressSearch = true }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("플레이스 검색하기")
                        .font(.system(size: 14))
                }
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 40))
        }
        .sheet(isPresented: $showAddressSearch) {
            addressSearch
        }
    }
    
    // 주소 찾기 버튼
    var addressSearch: some View {
        SearchKakaoPlaceView { result in
            self.address = result.roadAddress
            self.coord = result.coordString
        }
    }
    
    // 상세설명 텍스트필드
    var description: some View {
        VStack(alignment: .leading) {
            Text("설명 (옵션)")
                .font(.basic.light14)
                .padding(.bottom, 4)

            SearchBarView($descriptionText, "플레이스에 대해 설명해주세요", bgColor: .white, height: 40, isStroked: true)
        }
    }
    
    // 등록요청 버튼
    var registerButton: some View {
        Button(action: {
            viewModel.register(name: self.placeName, address: self.address, coord: self.coord) { result in
                if result == true {
                    presentation.wrappedValue.dismiss()
                } else {
                    print("Error") // TODO: 고치기
                }
            }
        }) {
            Text("플레이스 등록 요청하기")
                .font(.system(size: 14))
        }
        .disabled(placeName.isEmpty || address.isEmpty || restAddress.isEmpty)
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 52))
    }
}

struct RegisterPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPlaceView()
    }
}
