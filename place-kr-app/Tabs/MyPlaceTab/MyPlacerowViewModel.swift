//
//  MyPlacerowViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

class MyPlaceRowViewModel: ObservableObject {
    private var listManager: ListManager
    
    @Published var listName: String
    @Published var places = [TempPlaceInfoWrapper]() // 고치기
    @Published var selectionCount = 0
    @Published var isAllSelected = false
        
    private var placeDict = [UUID: TempPlaceInfoWrapper]() // 고치기
    
    func resetSelection() {
        isAllSelected = false
        for index in places.indices {
            places[index].isSelected = false
        }
        selectionCount = 0
    }
    
    func selectAll() {
        isAllSelected = true
        for index in places.indices {
            places[index].isSelected = true
        }
        selectionCount = places.count
    }
    
    func toggleAllSelection() {
        if isAllSelected {
            resetSelection()
        } else {
            selectAll()
        }
    }
    
    func toggleOneSelection(_ id: UUID) {
        isAllSelected = false
        let isSelected = placeDict[id]!.isSelected
        if isSelected {
            placeDict[id]?.isSelected = false
            selectionCount -= 1
        } else {
            placeDict[id]?.isSelected = true
            selectionCount += 1
            if selectionCount == places.count {
                isAllSelected = true
            }
        }
    }
    
    func deleteSelected() {
        self.places = places.filter { wrapper in
            if wrapper.isSelected {
                placeDict.removeValue(forKey: wrapper.id)
                return false
            } else {
                return true
            }
        }
        self.selectionCount = 0
    }
    
    init(list: PlaceList, listManager: ListManager) {
        self.listManager = listManager
        self.listName = list.name
        self.places = list.places
            .map({ (place: String) -> TempPlaceInfoWrapper in
                let placeWrapper = TempPlaceInfoWrapper(placeInfo: place, isSelected: false)
                placeDict[placeWrapper.id] = placeWrapper
                return placeWrapper
            })
//            .map({ (place: PlaceInfo) -> PlaceInfoWrapper in
//                let placeWrapper = PlaceInfoWrapper(placeInfo: place, isSelected: false)
//                placeDict[placeWrapper.id] = placeWrapper
//                return placeWrapper
//            })
        
        self.resetSelection()
    }
}

extension MyPlaceRowViewModel {
    class TempPlaceInfoWrapper: Hashable, Identifiable {
        let id = UUID()
        let placeInfo: String
        var isSelected: Bool
        
        init(placeInfo: String, isSelected: Bool) {
            self.placeInfo = placeInfo
            self.isSelected = isSelected
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: TempPlaceInfoWrapper, rhs: TempPlaceInfoWrapper) -> Bool {
            return lhs.id == rhs.id && lhs.id == rhs.id
        }
    }
    
    class PlaceInfoWrapper: Hashable, Identifiable {
        let id = UUID()
        let placeInfo: PlaceInfo
        var isSelected: Bool
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: PlaceInfoWrapper, rhs: PlaceInfoWrapper) -> Bool {
            return lhs.id == rhs.id && lhs.id == rhs.id
        }
        
        init(placeInfo: PlaceInfo, isSelected: Bool) {
            self.placeInfo = placeInfo
            self.isSelected = isSelected
        }
    }
}
