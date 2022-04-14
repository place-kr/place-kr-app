//
//  SearchFieldViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI
import Combine

/// 검색창에서 리턴한 정보를 바탕으로 관련 장소 정보를 서버에서 받아 오는 역할을 합니다.
/// 최초값은 현위치를 기반으로 설정됩니다.
class SearchManager: ObservableObject {
    @Published var places: [PlaceInfo]?   // 장소 정보 저장된 리스트
    @Published var searchKeyword = ""
    private var subscriptions = Set<AnyCancellable>()
    
    func reset() {
        places = [PlaceInfo]()
        searchKeyword = ""
    }
    
    /// API 서버에 장소 키워드 전달 후 관련 정보를 받아옵니다.
    func fetchPlaces(_ keyword: String) {
        PlaceSearchManager.getPlacesByName(name: keyword)
            .map { $0.results.map{ PlaceInfo(document: $0) }} 
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
                    self.searchKeyword = keyword
                    self.places = result
                    print(self.searchKeyword)
                    print(self.places as Any)
                }
            })
            .store(in: &subscriptions)
    }
    
    init(setCurrent: Bool = false) {
        /// 현위치를 초기 상태로 설정합니다.
        // TODO: 현위치가 좌표정보 외 아무런 정보를 갖고 있지 않음. 수정 필요.
//        LocationManager.shared.$currentCoord
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { coord in
//                guard let coord = coord else { return }
//                let defaultPlace = PlaceInfo(document: PlaceResponse.Document(
//                    id: UUID().uuidString,
//                    textAddress: "Dump",
//                    roadAddress: "Dump",
//                    name: "Dump",
//                    url: "Dump",
//                    x: String(coord.longitude),
//                    y: String(coord.latitude)))
//                self.places.append(defaultPlace)
//        })
//            .store(in: &subscriptions)
    }
}
