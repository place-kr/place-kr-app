//
//  SearchResultsView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/24.
//

import SwiftUI

struct SearchResultsView: View {
    // 모델을 받을지 리스트만 받을지 안에서 뷰모델을 따로 만들지 생각해보기
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel: SearchManager

    let keyword: String

    @State var isFocused = false
    @State var doNavigate = false
    @State var submitted: String = ""   // TODO: 개선할 수 있으면 하자

    
    init(keyword: String, _ viewModel: SearchManager = SearchManager()) {
        print("SSS \(keyword.isEmpty)")
        self.keyword = keyword
        self.viewModel = viewModel
        self.viewModel.fetchPlaces(keyword)
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: LazyView { SearchResultsView(keyword: submitted) },
                           isActive: $doNavigate) {
                EmptyView()
            }
            
            searchField
            
            // Bad network 경고 붙이기
            if let places = viewModel.places {
                if !isFocused {
                    if places.isEmpty {
                        noResultView
                    } else {
                        HStack {
                            searchResultHolder
                            Spacer()
                        }
                        
                        ScrollView {
                            ForEach(places, id: \.id) { place in
                                PlaceCardView(
                                    bgColor: Color(red: 246/255, green: 246/255, blue: 246/255),
                                    placeInfo: place
                                )
                                    .frame(height: 100)
                            }
                        }
                    }
                }
            } else {
                Spacer()
                ProgressView(style: .large)
            }
            
            
            
            Spacer()
        }
        .onAppear {
            self.viewModel.searchKeyword = keyword
        }
        .padding(.horizontal, 15)
        .navigationBarHidden(true)
    }
}

extension SearchResultsView {
    var searchResultHolder: some View {
        Text("'\(keyword)'에 대한 검색결과입니다")
            .font(.system(size: 14))
    }
    
    var searchField: some View {
        HStack {
            /// 이전 뷰로 pop
            Button(action: { self.presentation.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left") // TODO: Root 로 pop 할지 이대로 할지 결정
            }
            
            SearchBarView($viewModel.searchKeyword, isFocused: $isFocused, Color(red: 243/255, green: 243/255, blue: 243/255), "검색 장소를 입력하세요") {
                submitted = viewModel.searchKeyword
                doNavigate = true
            }
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
            Text("'\(keyword)'에 대한 검색 결과가 없습니다.\n아래 버튼을 통해 직접 플레이스를 등록하시거나.\n저희에게 플레이스 등록 요청을 해주세요.")
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
    
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(keyword: "")
    }
}

