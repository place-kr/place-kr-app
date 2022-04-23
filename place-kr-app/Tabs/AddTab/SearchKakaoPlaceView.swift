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
    @Published var page: Int? = 1
        
    func search(name: String, page: Int, completion: @escaping (Bool) -> Void) {
        self.progress = .inProcess
        
        // TODO: Paging
        PlaceSearchManager.getKakaoPlacesByName(name: name, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error) :
                    print(error)
                    self.progress = .failedWithError(error: error)
                    completion(false)
                case .finished:
                    print("Fetched")
                    self.progress = .finished
                    completion(true)
                }
                
                self.subscriptions.removeAll()
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }

                if value.meta.isEnd {
                    self.page = nil
                } else {
                    self.page! += 1
                }
                
                let placeInfos = value.documents.map{ KakaoPlaceInfo(document: $0) }
                if self.page == 1 {
                    self.searchResult = placeInfos
                } else {
                    self.searchResult.append(contentsOf: placeInfos)
                }
            })
            .store(in: &subscriptions)
    }
    
    init() {
        
    }
}

struct SearchKakaoPlaceView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = SearchKakaoPlaceViewModel()
    
    @State var text = ""
    @State var isBottom = false
    
    let completion: (KakaoPlaceInfo) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("닫기")
                }
                .foregroundColor(.black)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 15)

            SearchBarView($text, "키워드로 검색", bgColor: .white, height: 40, isStroked: true) {
                // 돋보기 버튼 클릭 시 액션
                if let page = viewModel.page {
                    viewModel.search(name: text, page: page) { _ in }
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 15)
            
            if viewModel.searchResult.isEmpty {
                Text("이렇게 검색해보세요")
                    .font(.basic.bold17)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 15)

            } else {
                Text("검색 결과")
                    .font(.basic.bold17)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                
                TrackableScrollView(reachedBottom: $isBottom, reachAction: {
                    print(viewModel.page)

                    // 바닥 터치 시 액션
                    if let page = viewModel.page {
                        viewModel.search(name: text, page: page) { result in
                            if result {
                                self.isBottom = false
                            }
                        }
                    }
                }) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.searchResult) { result in
                            Divider()
                                .padding(.vertical, 5)
                            RowView(name: result.name, roadAddress: result.roadAddress)
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
