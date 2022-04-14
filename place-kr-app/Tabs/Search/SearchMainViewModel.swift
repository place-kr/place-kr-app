//
//  AddTabViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//
import SwiftUI

class SearchMainViewModel: ObservableObject {
    // TODO: 더미 데이터 고치기
    @Published var categoriesData = ["일식", "중식", "한식", "일식", "중식", "한식", "일식", "중식", "한식"]
    @Published var searchKeyword = ""
    
    
    private let searchManager: SearchManager
    
    init(_ searchManager: SearchManager = SearchManager()) {
        self.searchManager = searchManager
    }
}
