//
//  UIMapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import NMapsMap

/// Naver map SDK에 관한 모든 것을 관리합니다
/// Document: https://navermaps.github.io/ios-map-sdk/guide-ko/3-1.html
struct UIMapView: UIViewRepresentable {
    @ObservedObject var place: SearchFieldViewModel
    
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
    
    /// 뷰에 업데이트가 있을 때마다 실행됩니다
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // 장소정보 비어있으면 리턴
        let places = place.places
        guard let place = places.first else {
            return
        }
        
        // Place(SearchFieldViewModel)에서 받은 좌표 토대로 카메라를 전환합니다
        // TODO: 현재는 첫번째 요소를 토대로 전환함. 여러개 들어올 때의 정보 처리 고민해보기
        let coord = NMGLatLng(lat: place.coord.1, lng: place.coord.0)
        
        // TODO: 장소 정보 리스트 토대로 마커 찍기, zoom level 이용할 것
        // 현재는 더미 데이터 사용
        let data = DummyDataModel().spots
        for datum in data {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: datum.x, lng: datum.y)
            marker.mapView = uiView.mapView
        }
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = .fly   // TODO: 애니메이션 종류 결정
        cameraUpdate.animationDuration = 1
        uiView.mapView.moveCamera(cameraUpdate)
    }
    
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        @ObservedObject var place: SearchFieldViewModel

        init(place: SearchFieldViewModel) {
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


fileprivate class DummyDataModel: ObservableObject {
    struct Spot: Codable {
        let x: Double
        let y: Double
        let name: String
    }
    
    @Published var spots = [Spot]()
    
    init() {
        for i in (0..<20) {
            let spot = Spot(x: 37.5666805 + Double(i) / 10000.0,
                            y: 126.9784147 + Double(i) / 10000.0,
                            name: "서울시청")
            self.spots.append(spot)
        }
    }
}
