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
        
    let sheetStyle = PartialSheetStyle(background: .solid(.white),
                                       accentColor: Color(UIColor.systemGray2),
                                       enableCover: false,
                                       coverColor: Color.white.opacity(0),
                                       blurEffectStyle: nil,
                                       cornerRadius: 20,
                                       minTopDistance: 350
    )
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack(spacing: 11) {
                    SearchFieldView(viewModel: place)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .padding(.leading, 15)
                    
                    NotificationView()
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .padding(.trailing, 15)
                }
                
                HStack {
                    Button(action: { partialSheetManager.showPartialSheet {
                        Text("전체")
                    }}) {
                        Text("전체")
                    }
                    .buttonStyle(CapsuledButtonStyle())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)

                    Button(action: { partialSheetManager.showPartialSheet {
                        Text("My")
                    }}) {
                        Text("My")
                    }
                    .buttonStyle(CapsuledButtonStyle())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)

                    Spacer()
                }
                .padding(.horizontal, 15)
                
                Spacer()
            }
            .zIndex(1)
            
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
                .background(Capsule().fill(.white))
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
