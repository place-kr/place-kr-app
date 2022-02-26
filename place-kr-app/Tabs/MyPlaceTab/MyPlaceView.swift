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
                                MyPlaceRowView(viewModel: MyPlaceRowViewModel(name: "Hola!"))
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
struct MyPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaceView()
    }
}
