//
//  UIMapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import NMapsMap

struct UIMapView: UIViewRepresentable {
    @ObservedObject var place: SearchManager
    
    func makeCoordinator() -> Coordinator {
        Coordinator(place: place)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        guard let place = place.places.first else {
            return
        }
        
        let coord = NMGLatLng(lat: place.coord.1, lng: place.coord.0)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = .fly   // TODO: 애니메이션 종류 결정
        cameraUpdate.animationDuration = 1
        uiView.mapView.moveCamera(cameraUpdate)
    }
    
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        @ObservedObject var place: SearchManager

        init(place: SearchManager) {
            self.place = place
        }

        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
//            print("카메라 변경 - reason: \(reason)")
        }

        func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
//            print("카메라 변경 - reason: \(reason)")
        }
    }

}
