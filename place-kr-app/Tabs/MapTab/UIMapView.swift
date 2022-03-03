//
//  UIMapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import NMapsMap

import Combine
class UIMapViewModel: ObservableObject {
    typealias bound = PlaceSearchManager.Boundary
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var places: [PlaceInfo]?
    @Published var currentBounds: NMGLatLngBounds?
    
    func fetchPlaces(in bounds: NMGLatLngBounds) {
        PlaceSearchManager.getPlacesByBoundary(
            bound(bounds.northEastLat, bounds.northEastLng, bounds.southWestLat, bounds.southWestLng))
            .map({ $0.results.map(PlaceInfo.init) })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Error happend: \(error)")
                case .finished:
                    print("Places successfully fetched")
                }
            }, receiveValue: { result in
                self.places = result
                print(result)
            })
            .store(in: &subscriptions)
    }
    
    init() {
        
    }
}

struct UIMapView: UIViewRepresentable {
    @ObservedObject var place: SearchManager
    @ObservedObject var viewModel: UIMapViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(place: place, viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        guard let place = place.places?.first else {
            return
        }
        
        let coord = NMGLatLng(lat: place.coord.1, lng: place.coord.0)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = .fly   // TODO: 애니메이션 종류 결정
        cameraUpdate.animationDuration = 1
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
            print("카메라 변경 - reason: \(reason)")
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            viewModel.currentBounds = mapView.contentBounds
            viewModel.fetchPlaces(in: mapView.contentBounds)
        }
    }

}
