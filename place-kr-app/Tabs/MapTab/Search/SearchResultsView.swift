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

    let originalKeyword: String // 변하지 않는 검색 결과를 잡고 있음

    @State var isFocused = false
    @State var navigateToResult = false
    @State var navigateToRegister = false
    @State var submitted: String = ""   // TODO: 개선할 수 있으면 하자, 변하는 결과를 잡고있다가 넘겨줌
    
    @State var page = 0
    @Binding var selection: TabsView.Tab

    
    init(keyword: String, selection: Binding<TabsView.Tab>, _ viewModel: SearchManager = SearchManager()) {
        self.originalKeyword = keyword
        self.viewModel = viewModel
        self._selection = selection

        self.viewModel.fetchPlaces(keyword, page: 0)
    }
    
    var body: some View {
        VStack {
            /// Navigate용 빈 뷰
            // 검색 결과로 go(result)
            NavigationLink(destination: LazyView { SearchResultsView(keyword: submitted, selection: $selection) },
                           isActive: $navigateToResult) {
                EmptyView()
            }
            
            // 플레이스 등록으로 go(register)
            NavigationLink(destination: LazyView { RegisterPlaceView() },
                           isActive: $navigateToRegister) {
                EmptyView()
            }
            
            searchField
                .padding(.horizontal, 15)

            // Bad network 경고 붙이기
            if let places = viewModel.places {
                if !isFocused && navigateToResult == false {
                    if places.isEmpty {
                        Group {
                            noResultDescription
                            Spacer()
                            
                            registerPlaceButton
                                .padding(.bottom, 25)
                        }
                        .padding(.horizontal, 15)

                    } else {
                        HStack {
                            searchResultHolder
                            Spacer()
                        }
                        .padding(.horizontal, 15)

                        ZStack {
                            Color.backgroundGray
                                .edgesIgnoringSafeArea(.all)
                                                        
                            ScrollView {
                                VStack {
                                    ForEach(places, id: \.id) { place in
                                        LightCardView(place: place, isFavorite: false)
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.white)
                                                .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                                        )
                                    }
                                }
                                .padding(.horizontal, 15)
                                .padding(.top, 10)
                                .padding(.bottom, 40)
                            }
                        }
                    }
                } else {
                    // 여기에 안 넣고 그냥 넣으면 배경이 말려올라감
                    Spacer()
                }
            } else {
                Spacer()
                CustomProgressView
            }
            
        }
        .onAppear {
            self.viewModel.searchKeyword = originalKeyword
        }
        .navigationBarHidden(true)
        .onTapGesture {
            endTextEditing()
        }
    }
}

extension SearchResultsView {
    var searchResultHolder: some View {
        Text("'\(originalKeyword)'에 대한 검색결과입니다")
            .font(.basic.normal14)
    }
    
    var searchField: some View {
        HStack {
            /// 이전 뷰로 pop
            Button(action: { self.presentation.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left") // TODO: Root 로 pop 할지 이대로 할지 결정
            }
            .foregroundColor(.black)
            
            SearchBarView($viewModel.searchKeyword, "검색 장소를 입력하세요",
                          isFocused: $isFocused,
                          bgColor: Color(red: 243/255, green: 243/255, blue: 243/255))
            {
                print(viewModel.searchKeyword, self.originalKeyword)
                if viewModel.searchKeyword == self.originalKeyword {
                    withAnimation(.easeInOut) {
                        isFocused = false
                    }
                } else {
                    submitted = viewModel.searchKeyword
                    navigateToResult = true
                }
            }
        }
    }
    
    var noResultDescription: some View {
        Group {
            Spacer()
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .padding(.bottom, 80)
            
            Text("찾으시는 플레이스가 없습니다")
                .font(.basic.bold17)
                .padding(.bottom, 15)
            Text("'\(originalKeyword)'에 대한 검색 결과가 없습니다.\n아래 버튼을 통해 직접 플레이스를 등록하시거나.\n저희에게 플레이스 등록 요청을 해주세요.")
                .multilineTextAlignment(.center)
                .font(.basic.normal14)
        }
    }
    
    var registerPlaceButton: some View {
        Button(action: {
            self.selection = .register
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                NavigationUtil.popToRootView()
            }
            
        }) {
            HStack {
                Spacer()
                Text("플레이스 등록하기")
                    .font(.basic.normal14)
                Spacer()
            }
        }
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white,  cornerRadius: 10,  isStroked: false, height: 50))
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(keyword: "", selection: .constant(.map))
    }
}

