//
//  FavoritePlacesManager.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/29.
//

import Combine

struct PlaceList {
    let name: String
    let places: [PlaceInfo]
}

class FavoritePlaceManager: ObservableObject {
    static let shared = FavoritePlaceManager()
    
    @Published var favoritePlacesLists: [PlaceList]
    
    init() {
        self.favoritePlacesLists = [PlaceList]()
        
        // MARK: DEBUG
        self.favoritePlacesLists = [
            PlaceList(name: "Mock1", places: [
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock1", x: "1", y: "1")),
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock1", x: "1", y: "1")),
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock1", x: "1", y: "1"))
            ]),
            PlaceList(name: "Mock2",places: [
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock2", x: "1", y: "1")),
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock2", x: "1", y: "1")),
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock2", x: "1", y: "1"))
            ]),
            PlaceList(name: "Mock3",places: [
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock3", x: "1", y: "1")),
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock3", x: "1", y: "1")),
                PlaceInfo(document: PlaceResponse.PlacePin(identifier: "", name: "Mock3", x: "1", y: "1"))
            ])
        ]
        
    }
}

