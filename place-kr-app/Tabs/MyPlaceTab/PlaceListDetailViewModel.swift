//
//  MyPlacerowViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI
import Combine

/// 리스트 내의 플레이스 정보를 관리하는 뷰모델입니다.
/// 삭제, 정렬 등의 기능을 갖습니다.
class PlaceListDetailViewModel: ObservableObject {
    private let listManager: ListManager
    private let list: PlaceList
   
    @Published var listColor: String
    @Published var listName: String
    @Published var places = [PlaceInfoWrapper]()
    @Published var selectionCount = 0
    @Published var isAllSelected = false
    @Published var progress: Progress = .ready
        
    private var placeDict = [String: PlaceInfoWrapper]() // 래퍼아이디 : 래퍼
    private var subscriptions = Set<AnyCancellable>()
    
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
        
        // 선택된 플레이스
        let selected = self.placeDict
            .filter { $1.isSelected == false }
        
        // 선택된 플레이스의 아이디들
        let selectedIDs = selected
            .keys
            .map { $0 }
        
        // 네트워크 리퀘스트
        listManager.editPlacesList(listID: self.list.identifier, placeIDs: selectedIDs) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case true:
                    // 성공하면 플레이스 갈아치우기
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
    
    func fetchMultipleInfos() {
        self.progress = .inProgress
        PlaceSearchManager.getMultiplePlacesByIdentifiers(self.list.places)
            .receive(on: DispatchQueue.main)
            .map { $0.results }
            .map { $0.map { PlaceInfo(document: $0) } }
            .map { $0.map { place -> PlaceInfoWrapper in
                let wrapper = PlaceInfoWrapper(placeInfo: place, isSelected: false)
                self.placeDict[wrapper.id] = wrapper
                return wrapper
            }}
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    print("[getMultiplePlacesByIdentifiers] Error happend: \(error)")
                case .finished:
                    print("PlaceInfo successfully fetched")
                }

                self.progress = .ready
            }, receiveValue: { placeInfos in
                self.places = placeInfos
            })
            .store(in: &subscriptions)
    }
    
    init(list: PlaceList, listManager: ListManager) {
        self.list = list
        self.listManager = listManager
        self.listName = list.name
        self.listColor = list.color
        
        self.resetSelection()
    }
}

extension PlaceListDetailViewModel {
    enum Progress {
        case inProgress
        case ready
    }
    
    class PlaceInfoWrapper: Hashable, Identifiable {
        let id: String
        let placeInfo: PlaceInfo
        var isSelected: Bool
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: PlaceInfoWrapper, rhs: PlaceInfoWrapper) -> Bool {
            return lhs.id == rhs.id && lhs.id == rhs.id
        }
        
        init(placeInfo: PlaceInfo, isSelected: Bool) {
            self.id = placeInfo.id
            self.placeInfo = placeInfo
            self.isSelected = isSelected
        }
    }
}
