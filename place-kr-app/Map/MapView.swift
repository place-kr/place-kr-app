//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI

struct MapView: View {
    @State var text = ""
    @State var coord = (0.0, 0.0)
    var body: some View {
        ZStack {
            VStack {
                SearchField
                Spacer()
            }
            .zIndex(1)
            UIMapView(coord: $coord)
                .edgesIgnoringSafeArea(.vertical)
        }
    }
}

extension MapView {
    struct TextFieldSearchButton: ViewModifier {
        @Binding var text: String
        @Binding var coord: (Double, Double)
        func body(content: Content) -> some View {
            HStack {
                Button(
                    action: {
                        self.text = ""
                        self.coord = (37.5666805, 126.9784147)
                    },
                    label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black)
                    }
                )
                content
                    .padding(.leading, 5)
            }
        }
    }
    
    var SearchField: some View {
        TextField("현위치: {자동 입력}", text: $text)
            .modifier(TextFieldSearchButton(text: $text, coord: $coord))
            .multilineTextAlignment(.leading)
            .frame(width: 280, height: 50)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(7)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
            .padding(.vertical)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
