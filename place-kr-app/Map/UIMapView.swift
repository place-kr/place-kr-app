//
//  UIMapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import NMapsMap

struct UIMapView: UIViewRepresentable {
    @Binding var coord: (Double, Double)
    let view = NMFNaverMapView()

    func makeUIView(context: Context) -> NMFNaverMapView {
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coord.0, lng: coord.1))
        cameraUpdate.animation = .easeIn
        view.mapView.moveCamera(cameraUpdate)
    }
}
