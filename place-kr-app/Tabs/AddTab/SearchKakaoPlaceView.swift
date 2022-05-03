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
            .padding(.top, 10)
            .padding(.horizontal, 15)
            
            if viewModel.searchResult.isEmpty && viewModel.isResultEmpty == false {
                Text("등록하고 싶은 플레이스를 검색해보세요")
                    .font(.basic.bold17)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 15)
                
                Text("지도를 통해 주소를 겁색합니다")
                    .font(.basic.normal14)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)

                Text("예) 서욽특별시 강남구 23길 2")
                    .font(.basic.bold14)
                    .padding(.top, 5)
                    .padding(.horizontal, 15)
            }
            else if viewModel.isResultEmpty {
                Text("검색 결과가 없습니다.")
            }
            else {
                Text("검색 결과")
                    .font(.basic.bold17)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                
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
                            Divider()
                                .padding(.vertical, 5)
                            
                            RequestCardView(name: result.name, address: result.roadAddress)
                                .onTapGesture {
                                    completion(result)
                                    presentationMode.wrappedValue.dismiss()
                                }
                        }

                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 40)
                }
                .overlay(
                    Group { if viewModel.progress == .inProcess {
                        CustomProgressView
                    }}
                )
            }
                
            Spacer()
        }
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
    struct RowView: View {
        let name: String
        let roadAddress: String
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("상호명")
                        .bold()
                        .encapsulate(mode: .dark)
                    Text(name)
                }
                HStack {
                    Text("주소")
                        .encapsulate(mode: .dark)
                    Text(roadAddress)
                }
            }
        }
    }
}
