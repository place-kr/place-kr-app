//
//  MyPlaceRowView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//

import SwiftUI
import PartialSheet


class MyPlaceRowViewModel: ObservableObject {
    @Published var listName: String
    @Published var places: [PlaceInfo]
    
    init(name: String) {
        self.listName = name
        self.places = Array(repeating: dummyPlaceInfo, count: 5)
    }
}

struct MyPlaceRowView: View {
    @EnvironmentObject var partialSheetManager : PartialSheetManager
    @ObservedObject var viewModel: MyPlaceRowViewModel
    
    var body: some View {
        SimplePlaceCardView(viewModel.listName,
                            subscripts: "\(viewModel.places.count) places",
                            image: UIImage())
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
        MyPlaceRowView(viewModel: MyPlaceRowViewModel(name: "Hola"))
    }
}
