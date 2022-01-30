//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import NMapsMap
import UIKit

final class UIMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> NMFNaverMapView {
      let view = NMFNaverMapView()
      view.showZoomControls = false
      view.mapView.positionMode = .direction
      view.mapView.zoomLevel = 17
      return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct MapView: View {
    var body: some View {
        UIMapView()
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
