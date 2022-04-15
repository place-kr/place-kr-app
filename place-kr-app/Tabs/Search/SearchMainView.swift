//
//  AddTabView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/22.
//

import SwiftUI

// 검색 완료시 네비게이션 뷰로 전환하는 모델 생각해볼 것

struct SearchMainView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel = SearchMainViewModel()
    @State var doNavigate = false
    
    var body: some View {
        VStack {
            /// Navgation용 빈 뷰. 검색 결과 뷰로 navigate.
            NavigationLink(destination: LazyView { SearchResultsView(keyword: viewModel.searchKeyword) }, 
                           isActive: $doNavigate) {
                EmptyView()
            }
            
            searchField
                .padding(.bottom, 30)
            
            
            /// 플레이스 텍스트가 비어있을 때 나타나는 뷰
            if viewModel.searchKeyword.isEmpty {
                searchHistory
                    .padding(.bottom, 40)
                
//                categories
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.searchKeyword = ""
        }
        .padding(.horizontal, 20)
        .navigationBarHidden(true)
        .onTapGesture {
            endTextEditing() 
        }
    }
}

extension SearchMainView {
    var searchField: some View {
        HStack {
            /// 이전 뷰로 pop
            Button(action: { self.presentation.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left") // TODO: Root 로 pop 할지 이대로 할지 결정
            }
            .foregroundColor(.black)
            
            SearchBarView($viewModel.searchKeyword, "검색 장소를 입력하세요", bgColor: Color(red: 243/255,  green: 243/255, blue: 243/255)) {
                // MARK: - Searchbar Action
                viewModel.saveQuery(viewModel.searchKeyword)
                doNavigate = true
            }
        }
    }
    
    public var searchHistory: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("내가 찾은 검색어")
                    .font(.system(size: 14))
                Spacer()
                Button(action: { viewModel.deleteHistory() }) {
                    Text("삭제하기")
                        .font(.system(size: 12))
                }
                .foregroundColor(.black)
            }
            
            // MARK: - 검색어 버튼
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.searchHistory, id: \.self) { query in
                        Button(action: {
                            viewModel.searchKeyword = query
                            doNavigate = true
                        }) {
                            Text(query)
                                .font(.system(size: 11))
                        }
                        .padding(1)
                        .buttonStyle(RoundedButtonStyle(bgColor: .white, textColor: .black, isStroked: true, width: 50, height: 27))
                    }
                }
            }
        }
    }
    
//    var categories: some View {
//        VStack(alignment: .leading) {
//            Text("카테고리별 플레이스 찾기")
//                .font(.system(size: 14))
//
//            UIGrid(columns: 2, list: viewModel.categoriesData) { category in
//                Button(action: {}) {
//                    HStack {
//                        Spacer()
//                        Text(category)
//                            .font(.system(size: 12))
//                        Spacer()
//                    }
//                }
//                .buttonStyle(RoundedButtonStyle(bgColor: .gray.opacity(0.3), textColor: .white, isStroked: false, height: 40))
//            }
//        }
//    }
    
}

struct AddTabView_Previews: PreviewProvider {
    static var previews: some View {
        SearchMainView()
    }
}
