//
//  MyPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/17.
//

import SwiftUI
import PartialSheet

// TODO: 서버에서 리스트 정보를 받아와야 할 것 같다

struct MyPlaceView: View {
    @EnvironmentObject var partialSheetManager : PartialSheetManager
    
    //TODO: Fix here
    @State var count = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                HStack {
                    Text("총 \(count)개의 플레이스 리스트가 있습니다")
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach((0..<count), id: \.self) { _ in
                            NavigationLink(destination: Text("올해 가보고 싶은 곳")) {
                                CardView(title: "올해 가보고 싶은 곳", subtitle: "3")
                                    .environmentObject(partialSheetManager)
                                    .frame(height: 70)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.white)
                                            .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                                    )
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 15)
            .navigationBarTitle("나의 플레이스", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {}) {
                        Text("추가하기")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
            )
            .addPartialSheet(style: sheetStyle)
        }
    }
}

extension MyPlaceView {
    struct CardView: View {
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
        
        var managePlaceList: some View {
            NavigationView {
                List {
                    Text("공유하기")
                    Text("리스트명 변경하기")
                    Text("플레이스 편집하기")
                    Text("삭제하기")
                }
                .listStyle(PlainListStyle())
                .environment(\.defaultMinListRowHeight, 50)
                .navigationBarItems(trailing: Button(action: {}) { Image(systemName: "xmark") })
                .navigationBarTitle("플레이스 리스트 관리")
            }
        }
    }
}

struct MyPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaceView()
    }
}
