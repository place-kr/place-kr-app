//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import PartialSheet

struct MapView: View {
    @ObservedObject var place = SearchFieldViewModel()
    @EnvironmentObject var partialSheetManager : PartialSheetManager
    
    @State var showEntireSheet = false
    @State var showMySheet = false
        
    let sheetStyle = PartialSheetStyle(background: .solid(.white),
                                       accentColor: Color(UIColor.systemGray2),
                                       enableCover: true,
                                       coverColor: Color.white.opacity(0.01),
                                       blurEffectStyle: nil,
                                       cornerRadius: 20,
                                       minTopDistance: 350
    )
    
    var body: some View {
        ZStack {
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
            
            /// 네이버 맵
            UIMapView(place: place)
                .edgesIgnoringSafeArea(.vertical)
        }
        .addPartialSheet(style: self.sheetStyle)
    }
}

extension MapView {
    struct CapsuledButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(Color.black)
                .font(.system(size: 14))
                .frame(width: 52, height: 34)
        }
    }
    
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
