//
//  MyPlacerowViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

class MyPlaceRowViewModel: ObservableObject {
    @Published var listName: String
    @Published var places: [PlaceInfo]
    
    init(name: String) {
        self.listName = name
        self.places = dummyPlaceInfoArray
    }
}
