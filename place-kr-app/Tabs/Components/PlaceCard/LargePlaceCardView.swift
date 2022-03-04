//
//  PlaceCardView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/23.
//

import SwiftUI

import Combine

class LargePlaceCardViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var name = ""
    @Published var saves: Int = 0
    
    init(id placeID: String) {
        PlaceSearchManager.getPlacesByIdentifier(placeID)
            .receive(on: DispatchQueue.main)
            .map({ PlaceInfo(document: $0) })
            .sink(receiveCompletion: { result in
                print(result)
                switch result {
                case .failure(let error):
                    print("Error happend: \(error)")
                case .finished:
                    print("LargePlaceCardView successfully fetched")
                }
            }, receiveValue: { value in
                self.name = value.name
                self.saves = value.saves
            })
            .store(in: &subscriptions)
    }
}

struct LargePlaceCardView: View {
    @ObservedObject var viewModel: LargePlaceCardViewModel
    
    init(id placeID: String) {
        self.viewModel = LargePlaceCardViewModel(id: placeID)
    }
    
    var body: some View {
        HStack() {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.5))
                .frame(width: 94, height: 94)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    Text("\(viewModel.name)")
                        .bold()
                        .font(.system(size: 24))
                        .padding(.trailing, 6)
                    Group {
                        Image(systemName: "star.fill")
                        Text("\(viewModel.saves)명이 저장")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                }
                .padding(.bottom, 4)
                
                HStack(alignment: .center, spacing: 6) {
                    Group {
                        Image(systemName: "person.fill")
                        Text("포로리님의 플레이스")
                    }
                    .font(.system(size: 12))
                }
                .padding(.bottom, 20)
                
                HStack(spacing: 5) {
                    Text("일식")
                        .encapsulate()
                    Text("아늑해요")
                        .encapsulate()
                    Text("깔끔해요")
                        .encapsulate()
                }

            }
            
            Spacer()
            
            VStack {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.gray)
                    }
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(CircleButtonStyle())
//                Spacer()
            }
        }
    }
}

struct LargePlaceCardView_Previews: PreviewProvider {
    static var previews: some View {
        LargePlaceCardView(id: "")
    }
}
