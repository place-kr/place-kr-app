//
//  MyPlacerowViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

class MyPlaceRowViewModel: ObservableObject {
    private let listManager: ListManager
    private let id: String
    
    @Published var listName: String
    @Published var places = [TempPlaceInfoWrapper]() // 고치기
    @Published var selectionCount = 0
    @Published var isAllSelected = false
    @Published var progress: Progress = .ready
        
    private var placeDict = [String: TempPlaceInfoWrapper]() // 고치기
    
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
    
    func toggleOneSelection(_ id: String) {
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
        self.progress = .inProgress
        
        let selected = self.placeDict
            .filter { $1.isSelected == true }
        
        let selectedIDs = selected
            .keys
            .map { $0 }
        
        listManager.editPlacesList(listID: self.id, placeIDs: selectedIDs) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case true:
                    self.placeDict = selected
                    self.selectionCount = 0
                    break
                case false:
                    break
                }
                
                self.progress = .ready
            }
        }
    }
    
    init(list: PlaceList, listManager: ListManager) {
        self.id = list.identifier
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
    enum Progress {
        case inProgress
        case ready
    }
    
    class TempPlaceInfoWrapper: Hashable, Identifiable {
        let id: String
        let placeInfo: String
        var isSelected: Bool
        
        init(placeInfo: String, isSelected: Bool) {
            self.id = placeInfo
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
