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
/// ex. 시야 안에 있는 장소 검색, 현위치로 전환
class UIMapViewModel: ObservableObject {
    typealias bound = PlaceSearchManager.Boundary
    
    private var subscriptions = Set<AnyCancellable>()
    var currentBounds: NMGLatLngBounds
    var currentPlaceID: String?
    
    @Published var places = [PlaceWrapper]()
    @Published var currentPosition: NMGLatLng
    @Published var isInCurrentPosition = true
    @Published var mapNeedsReload = false
    
    func setCurrentLocation() {
        self.currentPosition = NMGLatLng(from: LocationManager.shared.currentCoord)
    }
    
    private func listePlacePublisher(_ publisher: AnyPublisher<PlaceResponse, Error>) {
        publisher
            .map({ $0.results.map(PlaceInfo.init) })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Error happend: \(error)")
                case .finished:
                    print("API Places successfully fetched")
                }
            }, receiveValue: { data in
                // 받은 info를 맵뷰에서 쓰기 위한 래퍼로 치환
                self.places = data.map({ PlaceWrapper($0)})
                
                print("count: \(self.places.count), First content:\(self.places[0..<min(1, self.places.count)].first?.placeInfo.name as Any)...")
            })
            .store(in: &subscriptions)
    }
    
    func fetchPlaces(by keyword: String) {
        listePlacePublisher(PlaceSearchManager.getPlacesByName(name: keyword))
    }
    
    func fetchPlaces(in bounds: NMGLatLngBounds) {
        let bound = bound(bounds.northEastLat, bounds.northEastLng, bounds.southWestLat, bounds.southWestLng)
        listePlacePublisher(PlaceSearchManager.getPlacesByBoundary(bound))
    }
    
    init() {
        let offset: Double = 1 / 1000
        
        let coord = LocationManager.shared.currentCoord
        self.currentPosition = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
        self.currentBounds = NMGLatLngBounds(
            southWestLat: coord.latitude - offset,
            southWestLng: coord.longitude - offset,
            northEastLat: coord.latitude + offset,
            northEastLng: coord.longitude + offset
        )
        
        LocationManager.shared.$currentCoord
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { coord in
                self.currentPosition = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
                self.fetchPlaces(in: NMGLatLngBounds(
                    southWestLat: coord.latitude - offset,
                    southWestLng: coord.longitude - offset,
                    northEastLat: coord.latitude + offset,
                    northEastLng: coord.longitude + offset)
                )
            })
            .store(in: &subscriptions)
    }
}

extension UIMapViewModel {
    struct PlaceWrapper {
        let placeInfo: PlaceInfo
        let marker: NMFMarker
        
        init(_ placeInfo: PlaceInfo) {
            let position = placeInfo.lonlat
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: position.lat, lng: position.lon)
            
            self.placeInfo = placeInfo
            self.marker = marker
        }
    }
}

