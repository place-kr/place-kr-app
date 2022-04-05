//
//  MyPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/17.
//

import SwiftUI
import BottomSheet
// TODO: 서버에서 리스트 정보를 받아와야 할 것 같다

struct MyPlaceView: View {
    @EnvironmentObject var listManager: ListManager
    @State var navigateToNewList = false
    @State var bottomSheetPosition: PlaceListSheetPosition = .hidden

    var body: some View {
        VStack {
            Navigators
            
            VStack {
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

            // 플레이스 리스트
            VStack(spacing: 15) {
                HStack {
                    Text("총 \(listManager.placeLists.count)개의 플레이스 리스트가 있습니다")
                        .font(.basic.normal12)
                    Spacer()
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        // 리스트 카드 뷰
                        ForEach(listManager.placeLists, id: \.self) { list in
                            NavigationLink(
                                destination: LazyView {
                                    PlaceListDetailView(viewModel: PlaceListDetailViewModel(list: list, listManager: listManager))
                                },
                                label: {
                                    SimplePlaceCardView(list.name,
                                                        subscripts: "\(list.places.count) places",
                                                        image: UIImage(),
                                                        action: {
                                        withAnimation(.spring()) {
                                            bottomSheetPosition = .bottom
                                        }})
                                    .padding(.horizontal, 12)
                                })
                            .frame(height: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white)
                                    .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                            )
                            
                            .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
        }
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                     options: [
                        .animation(springAnimation), .background(AnyView(Color.white)), .cornerRadius(20), .absolutePositionValue,
                        .noBottomPosition, .swipeToDismiss, .tapToDismiss, .backgroundBlur(effect: .dark), 
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: -5)
                     ]
                     ,
                     headerContent: {
            HStack {
                Text("플레이스 리스트 관리")
                    .font(.system(size: 21, weight: .bold))
                    .padding(.top, 20)
                    .padding(.bottom, 13.5)
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        bottomSheetPosition = .hidden
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 21, weight: .bold))

                }
            }
            .padding(.horizontal, 25)
        },
                     mainContent: {
            managePlaceList
                .padding(.horizontal, 28)
        })
        .navigationBarTitle("") //this must be empty
        .navigationBarHidden(true)
    }
}

extension MyPlaceView {
    var Navigators: some View {
        NavigationLink(
            isActive: self.$navigateToNewList,
            destination: { RegisterNewListView().environmentObject(listManager) }) {
                EmptyView()
            }
    }
    
    var managePlaceList: some View {
        List {
            NavigationLink(destination: Text("공유하기")) {
                HStack(spacing: 9) {
                    Image(systemName: "square")
                    Text("공유하기")
                }
            }
            
            NavigationLink(destination: Text("리스트명 변경하기")) {
                HStack(spacing: 9) {
                    Image(systemName: "pencil")
                    Text("리스트명 변경하기")
                }
            }
            
            NavigationLink(destination: Text("플레이스 편집하기")) {
                HStack(spacing: 9) {
                    Image(systemName: "mappin")
                    Text("플레이스 편집하기")
                }
            }
            
            NavigationLink(destination: Text("삭제하기")) {
                HStack(spacing: 9) {
                    Image(systemName: "trash")
                    Text("삭제하기")
                }
            }
        }
        .font(.system(size: 14))
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, 50)
    }
}

struct MyPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaceView()
    }
}
