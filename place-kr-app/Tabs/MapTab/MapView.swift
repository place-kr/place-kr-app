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
    
    /// 현재 활성화된 시트의 종류를 저장, 리턴함
    @State var activeSheet: ActiveSheet = .placeInfo
    @State var bottomSheetPosition: SheetPosition = .hidden
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
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
                            .animation(springAnimation), .background(AnyView(Color.white)), .cornerRadius(10),
                            .allowContentDrag, .noBottomPosition, .swipeToDismiss,
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: -5)
                         ],
                         headerContent: {
                SheetView(active: activeSheet)
            }) {
                if placeInfoManager.placeInfo == nil {
                    ProgressView(style: UIActivityIndicatorView.Style.medium)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

extension MapView {
    enum ActiveSheet {
        case myPlace, entire, placeInfo
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
            }
        }
    }
    
    var SearchField: some View {
        ThemedTextField($searchText, "장소를 입력하세요", bgColor: .white, isStroked: false, position: .leading, buttonName: "magnifyingglass", buttonColor: .black) {
            print("tapped")
        }
    }
    /// 액션 버튼
    var InteractivButtons: some View {
        VStack {
            HStack {
                Button(action: {}) {
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
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
