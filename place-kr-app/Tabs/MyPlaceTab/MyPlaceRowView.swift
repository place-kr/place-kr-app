//
//  MyPlaceRowView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//

import SwiftUI
import PartialSheet

struct MyPlaceRowView: View {
    @EnvironmentObject var partialSheetManager : PartialSheetManager
    
    let image: Image? = nil
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.5))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                Text("\(subtitle) places")
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.leading, 14)
            
            Spacer()
            
            Button(action: {
                partialSheetManager.showPartialSheet({}) {
                    managePlaceList
                }}) {
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
        .padding(.horizontal, 12)
    }
}

extension MyPlaceRowView {
    var managePlaceList: some View {
        List {
            NavigationLink(destination: Text("공유하기")) {
                Text("공유하기")
            }
            
            NavigationLink(destination: Text("리스트명 변경하기")) {
                Text("리스트명 변경하기")
            }
            
            NavigationLink(destination: Text("플레이스 편집하기")) {
                Text("플레이스 편집하기")
            }
            
            NavigationLink(destination: Text("삭제하기")) {
                Text("삭제하기")
            }
        }
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, 50)
    }
}

struct MyPlaceRowView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaceRowView(title: "", subtitle: "")
    }
}
