//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import PartialSheet

struct MapView: View {
    @ObservedObject var place = SearchManager()
    @StateObject var mapViewModel = UIMapViewModel() // TODO: ??? 왜 됨?
    @EnvironmentObject var partialSheetManager : PartialSheetManager
    
    @State var showEntireSheet = false
    @State var showMySheet = false
    @State var showSheet = false
    @State var activeSheet: ActiveSheet = .placeInfo
    
    var body: some View {
        ZStack {
            /// 네이버 맵
            UIMapView(viewModel: mapViewModel, markerAction: { showSheet = true })
                .edgesIgnoringSafeArea(.vertical)
            
            VStack {
                Spacer()
                
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
                    SearchFieldView(viewModel: place)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .padding(.leading, 15)
                    
                    NotificationView()
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .padding(.trailing, 15)
                }
                
                /// 검색창 및 Sheet view 버튼
                HStack {
                    EntirePlaceButton
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)

                    MyPlaceButton
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)

                    sheetView
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                Spacer()
            }
            .zIndex(1)
        }
        .addPartialSheet(style: sheetStyle)
    }
}

extension MapView {
    enum ActiveSheet {
        case myPlace, entire, placeInfo
    }
    
    func showSheetRoutine() {
        self.showSheet = true
        activeSheet = .myPlace
    }
    
    var sheetView: some View {
        return EmptyView().partialSheet(isPresented: $showSheet) {
            switch activeSheet {
            case .myPlace:
                Text("INFO")
            case .entire:
                Text("전체")
            case .placeInfo:
                MyPlaceSheetView()
                    .frame(maxWidth: .infinity, maxHeight: 155)
                    .padding(.horizontal, 15)
            }
        }
    }
    
    var EntirePlaceButton: some View {
        func showSheet() {
            self.showSheet.toggle()
            activeSheet = .entire
        }
        
        return Button(action: { showSheet() }) {
            Text("전체")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(showEntireSheet ? .gray : .white))
    }
    
    var MyPlaceButton: some View {
        func showSheet() {
            self.showSheet.toggle()
            activeSheet = .myPlace
        }
        
        return Button(action: { showSheet() }) {
            Text("My")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(showMySheet ? .gray : .white))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
