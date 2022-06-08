//
//  SearchKakaoPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/14.
//

import SwiftUI
import Combine

class SearchKakaoPlaceViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var searchResult = [KakaoPlaceInfo]()
    @Published var progress: Progress = .ready
    @Published var isResultEmpty = false
    @Published var page: Int? = 1
        
    var previousQueryText = String()
        
    func search(name: String, page: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        self.progress = .inProcess
        
        // TODO: Paging
        PlaceSearchManager.getKakaoPlacesByName(name: name, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error) :
                    print(error)
                    completion(.failure(error))
                    self.progress = .failedWithError(error: error)
                case .finished:
                    print("Fetched")
                    completion(.success(()))
                    self.progress = .finished
                }
                
                self.subscriptions.removeAll()
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                
                if value.documents.isEmpty {
                    self.isResultEmpty = true
                } else {
                    self.isResultEmpty = false
                }
                                
                let placeInfos = value.documents.map{ KakaoPlaceInfo(document: $0) }
                if self.page == 1 {
                    self.searchResult = placeInfos
                } else {
                    self.searchResult.append(contentsOf: placeInfos)
                }
                
                if value.meta.isEnd {
                    self.page = nil
                } else {
                    self.page! += 1
                }
            })
            .store(in: &subscriptions)
    }
    
    init() {
    }
}

struct SearchKakaoPlaceView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = SearchKakaoPlaceViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    @State var text = ""
    @State var isBottom = false
    @State var isFocused = false
    @State var showWarning = false
    
    let completion: (KakaoPlaceInfo) -> Void
    
    init(completion: @escaping (KakaoPlaceInfo) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                
                SearchBarView($text, "검색 장소를 입력하세요",
                              isFocused: self.$isFocused, bgColor: Color(red: 243/255,  green: 243/255, blue: 243/255),
                              height: 48)
                {
                    if self.viewModel.previousQueryText == text {
                        return
                    }
                    
                    // 쿼리 리턴 시 액션
                    self.viewModel.page = 1
                    self.viewModel.previousQueryText = text
                    self.viewModel.search(name: text, page: 1) { _ in }
                }
            }
            .background(Color.white)
            .padding(.top, 10)
            .padding(.horizontal, 15)
            
            Divider()
                .padding(.top, 10)
            
            // 결과 표시
            Group {
                if viewModel.searchResult.isEmpty && viewModel.isResultEmpty == false {
                    Text("등록하고 싶은 플레이스를 검색해보세요")
                        .font(.basic.bold17)
                        .padding(.top, 30)
                        .padding(.horizontal, 20)

                    Text("지도를 통해 주소를 겁색합니다")
                        .font(.basic.regular14)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)

                    Text("예) 서욽특별시 강남구 23길 2")
                        .font(.basic.normal14)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                }
                else if viewModel.isResultEmpty {
                    HStack {
                        Spacer()
                        NoResult(query: viewModel.previousQueryText)
                        Spacer()
                    }
                }
                else {
                    Text("검색 결과")
                        .font(.basic.normal14)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 20)
                    
                    ZStack {
                        Color.backgroundGray
                            .edgesIgnoringSafeArea(.all)
                        
                        TrackableScrollView(reachedBottom: $isBottom, reachAction: {
                            // 바닥 터치 시 액션
                            if let page = viewModel.page {
                                viewModel.search(name: viewModel.previousQueryText,
                                                 page: page) { result in
                                    switch result {
                                    case .success(()):
                                        isBottom = true
                                        break
                                    case .failure(_):
                                        showWarning = true
                                        break
                                    }
                                }
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(viewModel.searchResult, id:\.id) { result in
                                    RequestCardView(name: result.name, address: result.roadAddress)
                                        .frame(height: 70)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white)
                                        )
                                        .onTapGesture {
                                            completion(result)
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                }
                            }
                            .padding(.top, 14)
                            .padding(.bottom, 40)
                            .padding(.horizontal, 20)
                        }
                        .overlay(
                            Group { if viewModel.progress == .inProcess {
                                CustomProgressView
                            }}
                        )
                    }
                }
            }
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showWarning) {
            basicSystemAlert
        }
        .onTapGesture {
            endTextEditing()
        }
        .padding(.top, 17)
    }
}
 
extension SearchKakaoPlaceView {
    struct NoResult: View {
        let query: String
        
        var body: some View {
            VStack(alignment: .center) {
                Spacer()
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 80)
                
                Text("찾으시는 플레이스가 없습니다")
                    .font(.basic.bold17)
                    .padding(.bottom, 15)
                Text("'\(self.query)'에 대한 검색 결과가 없습니다.\n올바른 주소를 입력해주세요.")
                    .multilineTextAlignment(.center)
                    .font(.basic.normal14)
                Spacer()
            }
        }
    }
    
    var backgroundFiller: some View {
        VStack {
            HStack {
                Spacer()
                Text("Filler for background")
                    .opacity(0)
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.backgroundGray)
    }
}
