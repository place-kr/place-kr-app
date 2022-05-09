//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import BottomSheet
import Combine

struct MapView: View {
    private var subscriptions = Set<AnyCancellable>()
    private var locationManager: LocationManager
    
    @StateObject var mapViewModel = UIMapViewModel()
    @StateObject var placeInfoManager = PlaceInfoManager()
    
    @EnvironmentObject var listManager: ListManager
    
    @Binding var selection: TabsView.Tab
    
    /// 현재 활성화된 시트의 종류를 저장, 리턴함
    @State var activeSheet: ActiveSheet = .placeInfo
    @State var bottomSheetPosition: SheetPosition = .hidden
    @State var listSheetPosition: MiddlePosition = .hidden
    
    @State var searchText = ""
    
    @State var navigateToRegisterNewListView = false
    @State var navigateToSearch = false
    
    @State var showWarning = false
    @State var alertCase: AlertCase = .error
    
    init(selection: Binding<TabsView.Tab>, _ locationManager: LocationManager = LocationManager.shared) {
        self._selection = selection
        self.locationManager = locationManager
    }
    
    var body: some View {
        ZStack {
            NavigationLink(destination: LazyView { SearchMainView(selection: $selection) }, isActive: $navigateToSearch) {
                    EmptyView()
                }
            
            /// 네이버 맵
            UIMapView(viewModel: mapViewModel)
                .edgesIgnoringSafeArea(.vertical)
            
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
                ZStack(alignment: .center) {
                    if mapViewModel.mapNeedsReload {
                        // MARK: 맵 리로드 버튼
                        Button(action: {
                            // 보이는 범위 안의 플레이스 페칭, 마커 생성, 마커 그리기
                            mapViewModel.fetchPlacesAndDrawMarkers(in: mapViewModel.currentBounds) { info in
                                markerAction(id: info.id)
                            }
                            withAnimation(springAnimation) {
                                mapViewModel.mapNeedsReload = false
                            }
                        }) {
                            // MARK: 버튼 디자인
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .font(Font.title.weight(.bold))
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(.gray.opacity(0.7))
                                Text("플레이스 불러오기")
                                    .foregroundColor(.black)
                                    .font(.basic.normal14)
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule().fill(.white)
                                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 0)
                            )
                        }
                        .transition(.opacity)
                        .zIndex(1)
                    }
                }
                .padding(.horizontal, 15)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    //MARK: - 현위치 버튼
                    Button(action: { mapViewModel.isCurrentPositionRequested = true }) {
                        Image(systemName: "scope")
                            .font(Font.body.weight(.bold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Circle().fill(.white)
                                .shadow(color: .gray.opacity(0.5),
                                        radius: 10, x: 0, y: 0))
                    }
                    .padding(17)
                }
            }
            .zIndex(1)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                     options: [
                        .animation(springAnimation), .background(AnyView(Color.white)), .cornerRadius(20),
                        .noBottomPosition, .swipeToDismiss,
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: -5)
                     ]
                     , content: {
            if placeInfoManager.placeInfo == nil {
                CustomProgressView
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
        .showAlert(show: $navigateToRegisterNewListView, alert: RegisterNewListAlertView(submitAction: {
            withAnimation(.easeInOut(duration: 0.2)) {
                navigateToRegisterNewListView = false
            }
        }, requestType: .post, completion: { result in
            switch result {
            case true:
                self.navigateToRegisterNewListView = false
            case false:
                self.alertCase = .error
                self.showWarning = true
            }
        }))
        .alert(isPresented: self.$showWarning) {
            switch alertCase {
            case .error:
                return basicSystemAlert
            case .duplicatePlace:
                return basicSystemAlert(title: "오류!", content: "이미 저장된 플레이스입니다")
            case .notImplemented:
                return basicSystemAlert(title: "해당 기능은 곧 추가될 예정입니다. 조금만 기다려주세요!", content: "")
            }
        }
    }
}

extension MapView {
    enum ActiveSheet {
        case placeInfo, favoriteList
    }
    
    enum AlertCase {
        case error, duplicatePlace, notImplemented
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
        case .placeInfo:
            if let placeInfo = placeInfoManager.placeInfo {
                VStack(alignment: .leading) {
                    HStack {
                        Text(placeInfo.name)
                            .font(.basic.bold20)
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
                Text("현위치:")
                
                if let location = locationManager.currentLocationName {
                    Text(location)
                        .foregroundColor(.black)
                } else {
                    Text("탐색 중...")
                        .foregroundColor(.gray.opacity(0.5))
                }

                Spacer()
            }
            .padding(.horizontal)
            .font(.basic.normal17)
            .background(RoundedRectangle(cornerRadius: 7)
                .fill(.white)
                .frame(height: 50)
            )
        }
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
                .font(.basic.bold(16))
                .frame(width: 35, height: 35)
        }
        
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
                    Image("placeNotAdded")
                        .foregroundColor(.gray)
                }
                Button(action: {
                    alertCase = .notImplemented
                    showWarning = true
                }) {
                    Image("share")
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(CircleButtonStyle())
        }
    }
    
    var AddingListSheetView: some View {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("리스트를 선택해주세요")
                        .font(.basic.bold21)
                    Spacer()
                    CloseButton
                }
                
                Divider()
                
                ScrollView(showsIndicators: false) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.navigateToRegisterNewListView = true
                            listManager.updateLists()
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image("createList")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                            
                            Text("새로운 리스트 만들기")
                                .font(.basic.normal12)
                            
                            Spacer()
                        }
                    }
                    
                    Divider()
                    ForEach(listManager.placeLists, id: \.identifier) { list in
                            Button(action: {
                                let listId = list.identifier
                                guard let selectedPlaceId = placeInfoManager.currentPlaceID else {
                                    return
                                }
                                
                                if list.places.contains(selectedPlaceId) {
                                    self.alertCase = .duplicatePlace
                                    self.showWarning = true
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
                                        self.alertCase = .duplicatePlace
                                        self.showWarning = true
                                        break
                                    }
                                }
                            }) {
                                HStack(spacing: 15) {
                                    Text(list.emoji)
                                        .font(.basic.bold14)
                                        .frame(width: 34, height: 34)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(colorFrom(hex: list.color).color)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(list.name)
                                            .font(.basic.normal12)
                                        Text("\(list.count) Places")
                                            .font(.basic.normal10)
                                    }
                                    
                                    
                                    Spacer()
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
        MapView(selection: .constant(.map))
    }
}
