//
//  MyPlacerowViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

extension MyPlaceRowViewModel {
    private struct PlaceInfoWrapper: Hashable, Identifiable {
        let id = UUID()
        let placeInfo: PlaceInfo
        var isSelected: Bool
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: PlaceInfoWrapper, rhs: PlaceInfoWrapper) -> Bool {
            return lhs.id == rhs.id && lhs.id == rhs.id
        }
    }
}

class MyPlaceRowViewModel: ObservableObject {
    @Published var listName: String
    @Published var places: [PlaceInfo]
    @Published var selectionStateDict = [String: Bool]()
    @Published var placesToBeDeleted = [PlaceInfo]()
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
    
    func toggleAllSelection() {
        if isAllSelected {
            resetSelection()
        } else {
            selectAll()
        }
    }
    
    func toggleOneSelection(_ placeID: String) {
        isAllSelected = false
        let isSelected = self.selectionStateDict[placeID, default: false]
        if isSelected {
            self.selectionStateDict[placeID] = false
        } else {
            self.selectionStateDict[placeID] = true
//            self.placesToBeDeleted.append()
        }
    }
    
    init(name: String) {
        self.listName = name
        self.places = dummyPlaceInfoArray
        self.resetSelection()
    }
}
