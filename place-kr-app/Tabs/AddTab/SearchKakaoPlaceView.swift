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
    @Published var page = 1
        
    func search(name: String, page: Int) {
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
                case .finished:
                    print("Fetched")
                    self.progress = .finished
                }
                
                self.subscriptions.removeAll()
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }

                self.searchResult = value
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
            
            SearchBarView($text, "키워드로 검색", bgColor: .white, height: 40, isStroked: true) {
                viewModel.search(name: text, page: viewModel.page)
            }
            .padding(.top, 10)
            .padding(.horizontal, 15)
            
            if viewModel.searchResult.isEmpty {
                Text("이렇게 검색해보세요")
                    .font(.basic.bold17)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 15)

            } else {
                HStack {
                    Text("검색 결과")
                        .font(.basic.bold17)
                        .padding(.vertical, 10)
                    Text(viewModel.searchResult.count == 15 ?
                         "(상위 \(viewModel.searchResult.count)개)" : "(\(viewModel.searchResult.count)개)"
                    )
                }
                .padding(.horizontal, 15)
                
                ScrollView {
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
                }
                .overlay(
                    Group { if viewModel.progress == .inProcess {
                        CustomProgressView
                    }}
                )
                .padding(.bottom, 40)
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
