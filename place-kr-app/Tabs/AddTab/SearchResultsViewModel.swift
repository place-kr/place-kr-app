//
//  SearchResultsViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/24.
//

import SwiftUI
import Combine

class SearchResultsViewModel: ObservableObject {
    @Published var places: [PlaceInfo]
    @Published var texts: String
    
    private var subsriptions = Set<AnyCancellable>()
    let keyword: String
    
    init(places: [PlaceInfo], keyword: String) {
        self.places = places
        self.keyword = keyword
        self.texts = keyword
        
//        self.$texts
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                print("@@@@")
//                self.presentation.wrappedValue.dismiss()
//            }
//            .store(in: &subsriptions)
    }
}
