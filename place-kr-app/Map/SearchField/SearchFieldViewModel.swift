//
//  SearchFieldViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI
import Combine

/// 검색창에서 리턴한 정보를 바탕으로 관련 장소 정보를 Kakao api에서 받아 오는 역할을 합니다.
/// 현위치를 기반으로 최초 설정됩니다.
class SearchFieldViewModel: ObservableObject {
    @Published var places = [PlaceInfo]()
    private var subscriptions = Set<AnyCancellable>()
    
    func fetchPlaces(_ input: String) {
        PlaceApiManager.getPlacesByName(name: input)
            .map({ $0.documents.map(PlaceInfo.init) })
            .sink(receiveCompletion: { response in
                switch response {
                case .failure(let error):
                    print("Failed with error: \(error)")
                    return
                case .finished:
                    print("Succeesfully finished!")
                }
            }, receiveValue: { result in
                DispatchQueue.main.async {
                    self.places = result
                    print(self.places)
                }
            })
            .store(in: &subscriptions)
    }
    
    init() {
        // 현위치를 초기 상태로 설정합니다. 
        LocationManager.shared.$currentCoord
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { coord in
                guard let coord = coord else { return }
                let defaultPlace = PlaceInfo(document: PlaceResponse.Document(
                    id: UUID().uuidString,
                    textAddress: "Dump",
                    roadAddress: "Dump",
                    name: "Dump",
                    url: "Dump",
                    x: String(coord.longitude),
                    y: String(coord.latitude)))
                self.places.append(defaultPlace)
        })
            .store(in: &subscriptions)
    }
}
