//
//  AddTabViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//
import SwiftUI

class SearchMainViewModel: ObservableObject {
    // TODO: 더미 데이터 고치기
    @Published var searchHistory = [String]()
    @Published var searchKeyword = ""
    
    private let searchManager: SearchManager
    
    func deleteHistory() {
        self.searchHistory = []
        UserInfoManager.deleteSearchHistory()
    }
    
    func saveQuery(_ query: String) {
        UserInfoManager.saveSearchHistory(query)
        if let history = UserInfoManager.searchHistory {
            self.searchHistory = history
        }
    }
    
    init(_ searchManager: SearchManager = SearchManager()) {
        self.searchManager = searchManager
        
        if let history = UserInfoManager.searchHistory {
            self.searchHistory = history
        }
    }
}
