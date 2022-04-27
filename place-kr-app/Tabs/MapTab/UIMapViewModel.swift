//
//  UIMapViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/03.
//

import SwiftUI
import NMapsMap
import Combine

/// 맵에 변경사항이 있을 때마다 그에 관련된 작업들을 진행합니다.
/// 여러 장소를 관리하는 것은 이곳, 한 개의 장소를 관리하는 것은 PlaceInfoManager로 갑니다.
/// ex. 시야 안에 있는 장소 검색, 현위치로 전환
class UIMapViewModel: ObservableObject {
    typealias bound = PlaceSearchManager.Boundary
    
    let view: NMFNaverMapView
    
    let activeMarkerImage = NMFOverlayImage(name: "placeActive")
    let inactiveMarkerImage = NMFOverlayImage(name: "placeDesactive")
    
    private var subscriptions = Set<AnyCancellable>()
    private var markers = [NMFMarker]()
    private let locationManager = LocationManager.shared
    
    var currentBounds: NMGLatLngBounds
    
    @Published var places = [PlaceWrapper]()
    @Published var currentPosition: NMGLatLng
    @Published var isCurrentPositionRequested = true
    @Published var mapNeedsReload = true
    @Published var selectdMarker = NMFMarker()
    
    func setCurrentLocation() {
        self.currentPosition = NMGLatLng(from: LocationManager.shared.currentCoord)
    }
    
    /// 플레이스 정보를 받아올 퍼블리셔를 결정하고 구독함
    private func listPlacePublisher(_ publisher: AnyPublisher<PlaceResponse, Error>,
                                    completion: @escaping (Result<[PlaceWrapper], Error>) -> Void) {
        publisher
            .map({ $0.results.map(PlaceInfo.init) })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Error happend: \(error)")
                    // 컴플리션으로 에러 전달
                    completion(.failure(error))
                case .finished:
                    print("API Places successfully fetched")
                }
            }, receiveValue: { data in
                // 받은 info를 맵뷰에서 쓰기 위한 래퍼로 치환
                self.places = data.map({ PlaceWrapper($0)})
                // 컴플리션으로 래퍼 전달
                completion(.success(self.places))
                
                print("count: \(self.places.count), First content:\(self.places[0..<min(1, self.places.count)].first?.placeInfo.name as Any)...")
            })
            .store(in: &subscriptions)
    }
    
    /// 퍼블리셔에 전달할 인자를 결정함
    func fetchPlaces(by keyword: String) {
        listPlacePublisher(PlaceSearchManager.getPlacesByName(name: keyword, page: 0)) { isSuccessed in
            // Do nothing
        }
    }
    
    /// 바운드로 장소 정보를 가져온 후 마커를 그림(범위에서 벗어난 마커는 삭제)
    func fetchPlacesAndDrawMarkers(in bounds: NMGLatLngBounds, action: @escaping (PlaceInfo) -> Void) {
        let bound = bound(bounds.northEastLat, bounds.northEastLng, bounds.southWestLat, bounds.southWestLng)
        self.listPlacePublisher(PlaceSearchManager.getPlacesByBoundary(bound)) { [weak self] result in
            guard let self = self else { return }
            
            switch(result) {
            case .success(let wrappers):
                if !self.markers.isEmpty { // 존재하는 마커가 있으면
                    _ = self.markers.map { $0.mapView = nil } // 비우기
                }
                
                self.markers = wrappers.map({ wrapper in // 그리기, 액션 더하기
                    let marker = wrapper.marker
                    marker.iconImage = self.inactiveMarkerImage
                    
                    // 마커에 터치 액션 부여
                    marker.touchHandler = { (m) -> Bool in
                        self.makeMarkersDefault(self.markers)
                        self.selectdMarker = marker
                        
                        // 카메라 무빙
                        let coord = wrapper.placeInfo.lonlat
                        let nCoord = NMGLatLng(lat:coord.lat, lng: coord.lon)
                        let cameraUpdate = NMFCameraUpdate(scrollTo: nCoord)
                        cameraUpdate.animation = .easeOut
                        cameraUpdate.animationDuration = 0.3
                        self.view.mapView.moveCamera(cameraUpdate)
                                    
                        withAnimation {
                            marker.iconImage = self.activeMarkerImage
                        }
                        action(wrapper.placeInfo)
                        return true
                    }
                    marker.mapView = self.view.mapView
                    return marker
                })
                
                break
            case .failure(let error):
                print("Error while fetching places: \(error), \(error.localizedDescription)")
                break
            }
        }
    }
    
    /// 마커 이미지 기본으로 변경
    func makeMarkersDefault(_ markers: [NMFMarker]) {
        for marker in markers {
            marker.iconImage = self.inactiveMarkerImage
        }
    }
    
    init() {
        self.view = NMFNaverMapView()
        
        let offset: Double = 1 / 1000
        
        let coord = locationManager.currentCoord
        
        self.currentPosition = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
        self.currentBounds = NMGLatLngBounds(
            southWestLat: coord.latitude - offset,
            southWestLng: coord.longitude - offset,
            northEastLat: coord.latitude + offset,
            northEastLng: coord.longitude + offset
        )
        
        locationManager.$currentCoord
            .prefix(2)
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] coord in
                guard let self = self else { return }
                print("SINKED")
                self.currentPosition = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
            })
            .store(in: &subscriptions)
    }
}

extension UIMapViewModel {
    struct PlaceWrapper {
        let placeInfo: PlaceInfo
        let marker: NMFMarker
        
        // MARK: 마커 세부옵션은 여기서!!!!
        init(_ placeInfo: PlaceInfo) {
            let position = placeInfo.lonlat
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: position.lat, lng: position.lon)
//            marker.isHideCollidedMarkers = true

            self.placeInfo = placeInfo
            self.marker = marker
        }
    }
}

