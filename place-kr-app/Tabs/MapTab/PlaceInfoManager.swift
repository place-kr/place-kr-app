//
//  PlaceInfoManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/09.
//

import SwiftUI
import Combine

class PlaceInfoManager: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var placeInfo: PlaceInfo?

    var currentPlaceID: String?
    let uuid = UUID()

    func fetchInfo(id placeID: String) {
        PlaceSearchManager.getPlacesByIdentifier(placeID)
            .receive(on: DispatchQueue.main)
            .map({ PlaceInfo(document: $0) })
            .sink(receiveCompletion: { result in
                print(result)
                switch result {
                case .failure(let error):
                    print("Error happend: \(error)")
                case .finished:
                    print("PlaceInfoManager successfully fetched")
                }
            }, receiveValue: { value in
                print("\(self.uuid) PlaceInfoManager: \(value)")
                self.placeInfo = value
            })
            .store(in: &subscriptions)
    }
}
