//
//  AddTabView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/22.
//

import SwiftUI

// 검색 완료시 네비게이션 뷰로 전환하는 모델 생각해볼 것

struct AddTabView: View {
    @ObservedObject var searchManager = SearchManager()
    // TODO: 더미 데이터 고치기
    var categoriesData = ["일식", "중식", "한식", "일식", "중식", "한식", "일식", "중식", "한식"]
    @State var text: String = ""
    
    var body: some View {
        VStack {
            searchField
                .padding(.bottom, 30)
            
            /// 플레이스 검색 결과가 비어있을 때 나타나는 뷰
            if searchManager.places.isEmpty && searchManager.searchText.isEmpty {
                searchHistory
                    .padding(.bottom, 40)
                
                categories
                Spacer()
            } else if searchManager.places.isEmpty && !searchManager.searchText.isEmpty {
                noResultView
                    .padding(.bottom, 20)
            } else {
                HStack {
                    searchResultHolder
                    Spacer()
                }
                
                ScrollView {
                    ForEach(searchManager.places, id: \.id) { place in
                        PlaceCardView(
                            bgColor: Color(red: 246/255, green: 246/255, blue: 246/255),
                            placeInfo: place
                        )
                            .frame(height: 100)
                    }
                }
                Spacer()
            }
            
        }
        .padding(.horizontal, 20)
    }
}

extension AddTabView {
    var searchField: some View {
        SearchBarView($text, Color(red: 243/255, green: 243/255, blue: 243/255),
                      "검색 장소를 입력하세요") {
            searchManager.fetchPlaces(text)
        }
    }
    
    var noResultView: some View {
        Group {
            Spacer()
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            Spacer()
            
            Text("찾으시는 플레이스가 없습니다")
                .font(.system(size: 17, weight: .bold))
                .padding(.bottom, 15)
            Text("'\(text)'에 대한 검색 결과가 없습니다.\n아래 버튼을 통해 직접 플레이스를 등록하시거나.\n저희에게 플레이스 등록 요청을 해주세요.")
                .multilineTextAlignment(.center)
                .font(.system(size: 14))
            
            Spacer()
            
            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("플레이스 직접 등록하기")
                        .font(.system(size: 14))
                    Spacer()
                }
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, height: 50))

            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("플레이스 등록 요청하기")
                        .font(.system(size: 14))
                    Spacer()
                }
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .white, textColor: .black, isStroked: true, height: 50))
        }
    }
    
    var searchHistory: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("내가 찾은 검색어")
                    .font(.system(size: 14))
                Spacer()
                Button(action: {}) {
                    Text("삭제하기")
                        .font(.system(size: 12))
                }
            }
            
            // TODO: 나중에 고쳐져야 함. 히스토리 UserDefault에 저장
            ScrollView(.horizontal) {
                HStack {
                    ForEach(1..<6, id: \.self) { _ in
                        Button(action: {}) {
                            Text("일식")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(RoundedButtonStyle(bgColor: .white, textColor: .black, isStroked: true, width: 50, height: 27))
                    }
                }
            }
        }
    }
    
    var searchResultHolder: some View {
        Text("'\(searchManager.searchText)'에 대한 검색결과입니다")
            .font(.system(size: 14))
    }
    
    // TODO: 여기 대체 왜 에러?
    var categories: some View {
        VStack(alignment: .leading) {
            Text("카테고리별 플레이스 찾기")
                .font(.system(size: 14))
            
            UIGrid(columns: 2, list: categoriesData) { category in
                Button(action: {}) {
                    HStack {
                        Spacer()
                        Text(category)
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
                .buttonStyle(RoundedButtonStyle(bgColor: .gray.opacity(0.3), textColor: .white, isStroked: false, height: 40))
            }
        }
    }
    
}

struct AddTabView_Previews: PreviewProvider {
    static var previews: some View {
        AddTabView()
    }
}
