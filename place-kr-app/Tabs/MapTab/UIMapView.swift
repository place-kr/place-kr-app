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
        if viewModel.isInCurrentPosition {
            let cameraUpdate = NMFCameraUpdate(scrollTo: viewModel.currentPosition)
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
            if reason == NMFMapChangedByGesture {
                self.viewModel.isInCurrentPosition = false
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
