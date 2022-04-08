//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import BottomSheet


struct MapView: View {
    @StateObject var mapViewModel = UIMapViewModel() // TODO: ??? 왜 됨?
    @StateObject var placeInfoManager = PlaceInfoManager()
    @EnvironmentObject var listManager: ListManager
    
    /// 현재 활성화된 시트의 종류를 저장, 리턴함
    @State var activeSheet: ActiveSheet = .placeInfo
    @State var bottomSheetPosition: SheetPosition = .hidden
    @State var listSheetPosition: MiddlePosition = .hidden
    
    @State var searchText = ""
    
    @State var navigateToRegisterNewListView = false
    @State var navigateToSearch = false
    
    var body: some View {
        
        ZStack {
            NavigationLink(destination: LazyView { AddTabView() }, isActive: $navigateToSearch) {
                    EmptyView()
                }
            
            /// 네이버 맵
            UIMapView(viewModel: mapViewModel)
                .edgesIgnoringSafeArea(.vertical)
            
            VStack {
                Spacer()
                
                if mapViewModel.mapNeedsReload {
                    /// 맵 리로드 버튼
                    Button(action: {
                        // 보이는 범위 안의 플레이스 페칭, 마커 생성, 마커 그리기
                        mapViewModel.fetchPlacesAndDrawMarkers(in: mapViewModel.currentBounds) { info in
                            markerAction(id: info.id)
                        }
                        withAnimation(springAnimation) {
                            mapViewModel.mapNeedsReload = false
                        }
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.black)
                            .shadow(radius: 5)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .padding(.bottom, 15)
            .zIndex(1)
            
            VStack(spacing: 10) {
                /// 검색창
                HStack(spacing: 11) {
                    SearchField
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .padding(.leading, 15)
                    
                    NotificationView()
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .padding(.trailing, 15)
                }
                
                /// 검색창 및 Sheet view 버튼 + Sheet pop 용 빈 뷰
                HStack {
                    EntirePlaceButton
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                    
                    MyPlaceButton
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                Spacer()
            }
            .zIndex(1)
        }
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                     options: [
                        .animation(springAnimation), .background(AnyView(Color.white)), .cornerRadius(20),
                        .noBottomPosition, .swipeToDismiss,
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: -5)
                     ]
                     , content: {
            if placeInfoManager.placeInfo == nil {
                ProgressView(style: UIActivityIndicatorView.Style.medium)
            } else {
                SheetView(active: activeSheet)
            }
        })
        .bottomSheet(bottomSheetPosition: self.$listSheetPosition,
                     options: [
                        .animation(springAnimation), .background(AnyView(Color.white)), .cornerRadius(20),
                        .noBottomPosition, .swipeToDismiss,
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: -5)
                     ]
                     , content: {
            SheetView(active: activeSheet)
        })
        .showAlert(show: navigateToRegisterNewListView, alert: RegisterNewListAlertView(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                navigateToRegisterNewListView = false
            }
        })
        )
    }
}

extension MapView {
    enum ActiveSheet {
        case myPlace, entire, placeInfo, favoriteList
    }
    
    func markerAction(id: String) {
        self.placeInfoManager.placeInfo = nil
        self.placeInfoManager.currentPlaceID = id
        self.placeInfoManager.fetchInfo(id: id)
        
        withAnimation(springAnimation) {
            self.bottomSheetPosition = .bottom
            self.activeSheet = .placeInfo
        }
    }
    
    @ViewBuilder
    func SheetView(active: ActiveSheet) -> some View {
        switch active {
        case .myPlace:
            Text("My place")
        case .entire:
            Text("전체")
        case .placeInfo:
            if let placeInfo = placeInfoManager.placeInfo {
                VStack(alignment: .leading) {
                    HStack {
                        Text(placeInfo.name)
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        InteractivButtons
                    }
                    
                    LargePlaceCardView(of: placeInfo)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        case .favoriteList:
            AddingListSheetView
        }
    }
    
    var SearchField: some View {
        Button(action: { self.navigateToSearch = true }) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("플레이스 검색")

                Spacer()
            }
                .background(RoundedRectangle(cornerRadius: 7)
                    .fill(.white)
                    .frame(height: 50)
                )
        }
//        ThemedTextField($searchText, "장소를 입력하세요", bgColor: .white, isStroked: false, isFocused: self.$isFocused, position: .leading, buttonName: "magnifyingglass", buttonColor: .black) {
//            print("tapped")
//        }
    }
    
    /// 닫기 버튼
    var CloseButton: some View {
        Button(action:{
            withAnimation(.spring()) {
                listSheetPosition = .hidden
            }
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.black)
                .font(.system(size: 16))
        }
        .frame(width: 20, height: 20)
    }
    
    /// 액션 버튼
    var InteractivButtons: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation(.spring()){
                        self.activeSheet = .favoriteList
                        self.bottomSheetPosition = .hidden
                        self.listSheetPosition = .middle
                    }
                }) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.gray)
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(CircleButtonStyle())
        }
    }
    
    var EntirePlaceButton: some View {
        func doShowSheet() {
            withAnimation(springAnimation) {
                bottomSheetPosition = .bottom
            }
        }
        
        return Button(action: { doShowSheet() }) {
            Text("전체")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(activeSheet == .entire ? .gray : .white))
    }
    
    var MyPlaceButton: some View {
        func doShowSheet() {
            withAnimation(springAnimation) {
                activeSheet = .myPlace
                bottomSheetPosition = .bottom
            }
        }
        
        return Button(action: { doShowSheet() }) {
            Text("My")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(activeSheet == .myPlace ? .gray : .white))
    }
    
    var AddingListSheetView: some View {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("리스트를 선택해주세요")
                        .font(.system(size: 21, weight: .bold))
                    Spacer()
                    CloseButton
                }

                Divider()

                ScrollView(showsIndicators: false) {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.gray)
                            .padding(5)
                            .background(Circle().fill(.gray.opacity(0.3)))
                        Text("새로운 리스트 만들기")
                            .font(.basic.normal12)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.navigateToRegisterNewListView = true
                            listManager.updateLists()
                        }
                    }
                    
                    Divider()
                        ForEach(listManager.placeLists, id: \.self) { list in
                            HStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.gray)
                                    .frame(width: 34, height: 34)
                                
                                Text(list.name)
                                
                                Spacer()
                            }
                            .onTapGesture {
                                let listId = list.identifier
                                guard let selectedPlaceId = placeInfoManager.currentPlaceID else {
                                    return
                                }
                                
                                if list.places.contains(selectedPlaceId) {
                                    print("Already exists")
                                    return
                                }
                                
                                listManager.addOnePlaceToList(listID: listId, placeID: selectedPlaceId) { result in
                                    switch result {
                                    case true:
                                        withAnimation(.spring()) {
                                            listSheetPosition = .hidden
                                        }
                                        break
                                    case false:
                                        print("Network: Already exists")
                                        break
                                    }
                                }
                            }
                            
                            Divider()
                        }
                }
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 10)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
