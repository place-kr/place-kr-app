//
//  SearchResultsViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/24.
//

import SwiftUI
import Combine

class SearchResultsViewModel: ObservableObject {
    @Published var places: [KakaoPlaceInfo]
    @Published var texts: String
    
    private var subsriptions = Set<AnyCancellable>()
    let keyword: String
    
    init(places: [KakaoPlaceInfo], keyword: String) {
        self.places = places
        self.keyword = keyword
        self.texts = keyword
    }
}
