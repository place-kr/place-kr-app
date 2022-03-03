//
//  UIMapViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/03.
//

import SwiftUI
import NMapsMap
import Combine

class UIMapViewModel: ObservableObject {
    typealias bound = PlaceSearchManager.Boundary
    private var subscriptions = Set<AnyCancellable>()
    var currentBounds: NMGLatLngBounds?
    
    @Published var places = [PlaceWrapper]()
    
    func fetchPlaces(in bounds: NMGLatLngBounds) {
        PlaceSearchManager.getPlacesByBoundary(bound(bounds.northEastLat, bounds.northEastLng, bounds.southWestLat, bounds.southWestLng))
            .map({ $0.results.map(PlaceInfo.init) })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print(result)
                switch result {
                case .failure(let error):
                    print("Error happend: \(error)")
                case .finished:
                    print("Places successfully fetched")
                }
            }, receiveValue: { data in
                self.places = data
                    .map({ placeInfo in
                        PlaceWrapper(placeInfo)
                    })
                
                print("count: \(self.places.count) \(self.places[0..<min(self.places.count, 10)])...")
            })
            .store(in: &subscriptions)
    }
    
    init() {
        
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

