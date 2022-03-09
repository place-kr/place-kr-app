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
                SheetHeader
            }) {
                if placeInfoManager.placeInfo != nil {
                    SheetContent
                        .padding([.horizontal, .top])
                } else {
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
    
    var SheetHeader: some View {
        VStack(alignment: .leading) {
            Text("Wuthering Heights")
                .font(.title).bold()
            
            SheetView(active: activeSheet)
        }
    }
    
    var SheetContent: some View {
        VStack(spacing: 0) {
            Text("대통령의 임기는 5년으로 하며, 중임할 수 없다. 모든 국민은 그 보호하는 자녀에게 적어도 초등교육과 법률이 정하는 교육을 받게 할 의무를 진다. 지방의회의 조직·권한·의원선거와 지방자치단체의 장의 선임방법 기타 지방자치단체의 조직과 운영에 관한 사항은 법률로 정한다. 법률이 헌법에 위반되는 여부가 재판의 전제가 된 경우에는 법원은 헌법재판소에 제청하여 그 심판에 의하여 재판한다. 모든 국민은 소급입법에 의하여 참정권의 제한을 받거나 재산권을 박탈당하지 아니한다.")
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Button(action: {}, label: {
                    Text("Read More")
                        .padding(.horizontal)
                })
                
                Spacer()
                
                Button(action: {}, label: {
                    Image(systemName: "bookmark")
                })
            }
            .padding(.top)
            
            Spacer(minLength: 0)
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
                LargePlaceCardView(of: placeInfo)
            }
        }
    }
    
    var SearchField: some View {
        ThemedTextField($searchText, "장소를 입력하세요", bgColor: .white, isStroked: false, position: .leading, buttonName: "magnifyingglass", buttonColor: .black) {
            print("tapped")
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
