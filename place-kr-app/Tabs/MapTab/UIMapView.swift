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
    @ObservedObject var viewModel: UIMapViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(place: place, viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.showCompass = false
        
        view.mapView.positionMode = .direction
        view.mapView.minZoomLevel = 7
        view.mapView.zoomLevel = 17
        
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        guard let place = place.places?.first else {
            return
        }
        
        let coord = NMGLatLng(lat: place.coord.1, lng: place.coord.0)
        print("Markers: \(viewModel.places.count)")
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = .fly   // TODO: 애니메이션 종류 결정
        cameraUpdate.animationDuration = 1
        
        NMFMarker(position: NMGLatLng(lat: 37.56668, lng: 126.978415)).mapView = uiView.mapView
        uiView.mapView.moveCamera(cameraUpdate)
    }
    
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        @ObservedObject var place: SearchManager
        @ObservedObject var viewModel: UIMapViewModel


        init(place: SearchManager, viewModel: UIMapViewModel) {
            self.place = place
            self.viewModel = viewModel
        }

        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
//            print("카메라 변경 - reason: \(reason)")
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            // TODO: 시점 변경 후 리로드 물어보기
            viewModel.currentBounds = mapView.contentBounds
            viewModel.fetchPlaces(in: mapView.contentBounds)
            _ = viewModel.places
                .map { place in
                    place.marker.mapView = mapView
                }
        }
    }

}
