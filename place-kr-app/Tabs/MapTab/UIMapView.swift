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
    
    /// 현재는 웬만하면 카메라 업데이트 용으로만 사용 중
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // 최초실행 or 현위치로 이동 시 카메라 업데이트
        if viewModel.isInCurrentPosition {
            let cameraUpdate = NMFCameraUpdate(scrollTo: viewModel.currentPosition)
            uiView.mapView.moveCamera(cameraUpdate)
            
            // 마커 그리기
            for place in viewModel.places {
                place.marker.mapView = uiView.mapView
            }
        }
        
//        } else if !places.isEmpty, let firstPlace = places.first {
//             TODO: 검색 후 상호작용
//            let place = firstPlace.placeInfo
//            let coord = NMGLatLng(lat: place.lonlat.lat, lng: place.lonlat.lon)
//
//            let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
//            cameraUpdate.animation = .fly
//            cameraUpdate.animationDuration = 1
//
//            uiView.mapView.moveCamera(cameraUpdate)
//        }
    }
    
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        @ObservedObject var viewModel: UIMapViewModel


        init(viewModel: UIMapViewModel) {
            self.viewModel = viewModel
        }
        
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            //            print("카메라 변경 - reason: \(reason)")
            if reason == NMFMapChangedByGesture {
                self.viewModel.isInCurrentPosition = false
            }
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            if self.viewModel.isInCurrentPosition == false {
                self.viewModel.currentBounds = mapView.contentBounds
                self.viewModel.currentPosition = mapView.cameraPosition.target
                self.viewModel.fetchPlaces(in: mapView.contentBounds)
                
                for place in viewModel.places {
                    print("idle: \(place.marker)")
                    place.marker.mapView = mapView
                }
            }
        }
    }
}
