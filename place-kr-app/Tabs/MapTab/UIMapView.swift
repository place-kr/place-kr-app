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
    private let locationManager = LocationManager.shared
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = viewModel.view
        view.showZoomControls = false
        view.showCompass = false
        
        view.mapView.positionMode = .direction
        view.mapView.minZoomLevel = 7
        view.mapView.zoomLevel = 16
        
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        
        return view
    }
    
    /// 현재는 웬만하면 카메라 업데이트 용으로만 사용 중
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // 최초실행 or 현위치로 이동 시 카메라 업데이트
        if viewModel.isCurrentPositionRequested && locationManager.isCurrentPosition == true {
            DispatchQueue.global(qos: .utility).async {
                locationManager.updateLocationDescription(coord: locationManager.currentCoord)
            }
                    
            let coord = locationManager.currentCoord
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coord.latitude, lng: coord.longitude))
            uiView.mapView.moveCamera(cameraUpdate)
            viewModel.isCurrentPositionRequested = false
        }
    }
    
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        @ObservedObject var viewModel: UIMapViewModel

        init(viewModel: UIMapViewModel) {
            self.viewModel = viewModel
        }
        
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            //            print("카메라 변경 - reason: \(reason)")
            if reason == NMFMapChangedByGesture {
                self.viewModel.isCurrentPositionRequested = false
                withAnimation(springAnimation) {
                    self.viewModel.mapNeedsReload = true
                }
            }
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            print("@ mapViewCameraIdle")
            self.viewModel.currentBounds = mapView.contentBounds
        }
    }
}
