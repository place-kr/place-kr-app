//
//  MyPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/17.
//

import SwiftUI
// TODO: 서버에서 리스트 정보를 받아와야 할 것 같다

struct MyPlaceView: View {
    @EnvironmentObject var favoritePlacesListManager: FavoritePlacesListManager
    @State var navigateToNewList = false
    
    var body: some View {
        let lists = favoritePlacesListManager.favoritePlacesLists
        VStack {
            
            VStack {
                Navigators
                
                // 페이지 헤더 부분
                PageHeader(title: "나의 플레이스", trailing: "추가하기", trailingAction: {
                    self.navigateToNewList = true
                })
                .padding(.bottom, 18)
                .padding(.horizontal, 15)

                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(maxHeight: 0.5)
                    .padding(.bottom, 18)
            }
            .padding(.top, 20)

            
            VStack(spacing: 15) {
                HStack {
                    Text("총 \(lists.count)개의 플레이스 리스트가 있습니다")
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(lists.indices, id: \.self) { _ in
                            let viewModel = MyPlaceRowViewModel(name: "Hola!")
                            NavigationLink(destination: PlaceListDetailView().environmentObject(viewModel)) {
                                MyPlaceRowView(viewModel: viewModel)
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
            .padding(.horizontal, 15)
        }
        .navigationBarTitle("") //this must be empty
        .navigationBarHidden(true)
    }
}

extension MyPlaceView {
    var Navigators: some View {
        NavigationLink(
            isActive: self.$navigateToNewList,
            destination: { RegisterNewListView().environmentObject(favoritePlacesListManager) }) {
                EmptyView()
        }
    }
}

struct MyPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaceView()
    }
}
