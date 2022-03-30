//
//  NewListAlertView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/29.
//

import SwiftUI

struct RegisterNewListView: View {
    @EnvironmentObject var viewModel: FavoritePlaceManager
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var name = ""
    
    let colors: [Color] = [.gray]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("리스트 만들기")
                .font(.basic.largetitle)
            
            Text("리스트명을 입력하세요")
                .font(.basic.subtitle)
                .padding(.bottom, 15)
            ThemedTextField($name, "리스트명을 입력해주세요",
                            bgColor: .gray.opacity(0.3),
                            isStroked: false,
                            position: .trailing,
                            buttonName: "photo",
                            buttonColor: .gray.opacity(0.5),
                            action: {})
            .padding(.bottom, 14)
            
            Text("리스트 컬러를 선택하세요")
                .padding(.bottom, 14)
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    ForEach(0..<5, id: \.self) { index in
                        let color = colors[0]
                        Circle().fill(color)
                            .frame(width: 50, height: 50)
                        if index != 4 {
                            Spacer()
                        }
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    ForEach(0..<5, id: \.self) { index in
                        let color = colors[0]
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                        if index != 4 {
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    self.viewModel.favoritePlacesLists.append(PlaceList(name: name, places: [PlaceInfo]()))
                    self.mode.wrappedValue.dismiss()
                }) {
                    Text("입력완료")
                }
                .disabled(name.isEmpty)
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, width: 147, height: 40))
                .padding(.top, 25)
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
        .padding(.horizontal, 25)
    }
}


struct RegisterNewListView_Preview: PreviewProvider {
    static var previews: some View {
        RegisterNewListView()
    }
}
