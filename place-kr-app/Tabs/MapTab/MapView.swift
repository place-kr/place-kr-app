//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI

struct MapView: View {
    @StateObject var mapViewModel = UIMapViewModel() // TODO: ??? 왜 됨?
    
    @State var showSheet = false
    @State var activeSheet: ActiveSheet = .placeInfo
    
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                /// 네이버 맵
                UIMapView(viewModel: mapViewModel, markerAction: {
                    withAnimation(.spring()) {
                        self.showSheet = true
                        self.activeSheet = .placeInfo
                    }
                })
                    .edgesIgnoringSafeArea(.vertical)
                
                VStack {
                    Spacer()
                     
                    // TODO: 맵 리로드 버튼 - 나중에 수정
                    Button(action: { mapViewModel.mapNeedsReload = false }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.black)
                            .shadow(radius: 5)
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

//                        sheetView
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    Spacer()
                }
                .zIndex(1)
            }
            .showSheet(show: $showSheet, sheet: sheetView(active: activeSheet)
            )
            .navigationBarHidden(true)
        }
    }
}

extension MapView {
    enum ActiveSheet {
        case myPlace, entire, placeInfo
    }
    
    @ViewBuilder
    func sheetView(active: ActiveSheet) -> some View {
        switch active {
        case .myPlace:
            Text("My place")
        case .entire:
            Text("전체")
        case .placeInfo:
            if let placeID = mapViewModel.currentPlaceID {
                LazyView {
                    LargePlaceCardView(id: placeID)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 20)
                }
            } else {
                ProgressView(style: UIActivityIndicatorView.Style.medium)
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
            withAnimation(.spring()) {
                activeSheet = .entire
                self.showSheet.toggle()
            }
        }
        
        return Button(action: { doShowSheet() }) {
            Text("전체")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(activeSheet == .entire && showSheet ? .gray : .white))
    }
    
    var MyPlaceButton: some View {
        func doShowSheet() {
            withAnimation(.spring()) {
                activeSheet = .myPlace
                self.showSheet.toggle()
            }
        }
        
        return Button(action: { doShowSheet() }) {
            Text("My")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(activeSheet == .myPlace && showSheet ? .gray : .white))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
