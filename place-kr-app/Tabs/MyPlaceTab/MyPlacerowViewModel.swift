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
    @Published var selectionStateDict = [String: Bool]()
    @Published var isAllSelected = false
    
    func resetSelection() {
        isAllSelected = false
        _ = self.places.map({ place in
            self.selectionStateDict[place.id] = false
        })
    }
    
    func selectAll() {
        isAllSelected = true
        _ = self.places.map({ place in
            self.selectionStateDict[place.id] = true
        })
    }
    
    func toggleSelection() {
        if isAllSelected {
            resetSelection()
        } else {
            selectAll()
        }
    }
    
    func changeSelectionState(_ placeID: String) {
        isAllSelected = false
        let isSelected = self.selectionStateDict[placeID, default: false]
        if isSelected {
            self.selectionStateDict[placeID] = false
        } else {
            self.selectionStateDict[placeID] = true
        }
    }
    
    init(name: String) {
        self.listName = name
        self.places = dummyPlaceInfoArray
        self.resetSelection()
    }
}
