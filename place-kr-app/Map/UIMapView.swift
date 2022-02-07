//
//  UIMapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import NMapsMap

struct UIMapView: UIViewRepresentable {
//    @ObservedObject var place: SearchFieldViewModel
    
    let view = NMFNaverMapView()
    let coord: (Double, Double)

    func makeCoordinator() -> Coordinator {
        return Coordinator(coord: coord)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
//        guard let place = place.places.first else {
//            print("It's returned")
//            return
//        }
        
//        print("Being called \(place.coord.1) \(place.coord.0)")
//        let coord = NMGLatLng(lat: place.coord.1, lng: place.coord.0)
        let c = NMGLatLng(lat: coord.1, lng: coord.0)
        print("Coord set to \(c.lat) \(c.lng)")
        moveTo(c)
    }
    
    func moveTo(_ coord: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
//        cameraUpdate.animation = .easeIn
//        cameraUpdate.animationDuration = 2
        view.mapView.moveCamera(cameraUpdate) { isCancelled in
            if isCancelled {
                print("카메라 이동 취소")
            } else {
                print("카메라 이동 완료")
            }
        }
    }
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
//        @ObservedObject var place: SearchFieldViewModel

//        init(place: SearchFieldViewModel) {
//            self.place = place
//        }
        
        let coord: (Double, Double)
        
        init(coord: (Double, Double)) {
            self.coord = coord
        }

        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            print("카메라 변경 - reason: \(reason)")
        }

        func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
            print("카메라 변경 - reason: \(reason)")
        }
    }

}
