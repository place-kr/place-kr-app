//
//  SearchFieldViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI
import Combine

class SearchFieldViewModel: ObservableObject {
    @Published var places = [PlaceInfo]()
    
    private var subscriptions = Set<AnyCancellable>()
    
    func fetchWrittenPlaces(_ input: String) {
        PlaceApiManager.getPlace(input)
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
}
