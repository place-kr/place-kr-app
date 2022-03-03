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
    @ObservedObject var mapViewModel = UIMapViewModel()
    @EnvironmentObject var partialSheetManager : PartialSheetManager
    
    @State var showEntireSheet = false
    @State var showMySheet = false
    
    var body: some View {
        ZStack {
            /// 네이버 맵
            UIMapView(viewModel: mapViewModel)
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
    var EntirePlaceButton: some View {
        func showSheet() {
            showEntireSheet.toggle()
        }
        
        return Button(action: { showSheet() }) {
            Text("전체")
        }
        .partialSheet(isPresented: $showEntireSheet) {
            Text("전체")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(showEntireSheet ? .gray : .white))
    }
    
    var MyPlaceButton: some View {
        func showSheet() {
            showMySheet.toggle()
        }
        
        return Button(action: { showSheet() }) {
            Text("My")
        }
        .partialSheet(isPresented: $showMySheet) {
            MyPlaceSheetView()
                .frame(maxWidth: .infinity, maxHeight: 155)
                .padding(.horizontal, 15)
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
