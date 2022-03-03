//
//  UIMapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import NMapsMap

struct UIMapView: UIViewRepresentable {
    @ObservedObject var viewModel: UIMapViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
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
        let places = viewModel.places
        
        if let currentPosition = viewModel.currentPosition,
                  viewModel.isInCurrentPosition == true {
            let cameraUpdate = NMFCameraUpdate(scrollTo: currentPosition)
            uiView.mapView.moveCamera(cameraUpdate)
        } else if !places.isEmpty, let firstPlace = places.first {
            let place = firstPlace.placeInfo
            let coord = NMGLatLng(lat: place.lonlat.lat, lng: place.lonlat.lon)

            let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
            cameraUpdate.animation = .fly
            cameraUpdate.animationDuration = 1
            
            uiView.mapView.moveCamera(cameraUpdate)
        }
    }
    
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        @ObservedObject var viewModel: UIMapViewModel


        init(viewModel: UIMapViewModel) {
            self.viewModel = viewModel
        }
        
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            //            print("카메라 변경 - reason: \(reason)")
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            // TODO: 시점 변경 후 리로드 물어보기
            //            if viewModel.mapNeedsReload == false {
            viewModel.currentBounds = mapView.contentBounds
            viewModel.fetchPlaces(in: mapView.contentBounds)
            _ = viewModel.places
                .map { place in
                    place.marker.mapView = mapView
                }
            viewModel.isInCurrentPosition = false
            print(viewModel.places.first as Any, viewModel.isInCurrentPosition)
            //                viewModel.mapNeedsReload = true
            //            }
        }
    }
}
