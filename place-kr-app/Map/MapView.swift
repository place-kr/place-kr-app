//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI

struct MapView: View {
    @ObservedObject var place = SearchFieldViewModel()
    var body: some View {
        ZStack {
            VStack {
                SearchFieldView(viewModel: place)
                Spacer()
            }
            .zIndex(1)
            UIMapView(place: place)
                .edgesIgnoringSafeArea(.vertical)
        }
    }
}
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
