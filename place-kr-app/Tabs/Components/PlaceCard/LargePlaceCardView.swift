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
    
    @Published var placeInfo: PlaceInfo
    @Published var name: String?
    @Published var saves: Int?
    
    init(info: PlaceInfo) {
        self.name = info.name
        self.saves = info.saves
        self.placeInfo = info
        print("\(Date().timeIntervalSince1970) LargeCardView")
    }
}

struct LargePlaceCardView: View {
    @ObservedObject var viewModel: LargePlaceCardViewModel
    @State var showNavigation = false
    
    init(of placeInfo: PlaceInfo) {
        self.viewModel = LargePlaceCardViewModel(info: placeInfo)
    }
    
    var body: some View {
        if viewModel.name != nil {
            HStack(alignment: .top) {
                
                // 여기로 네비게이션
//                NavigationLink(destination: LazyView { PlaceDetailView(placeInfo: viewModel.placeInfo) }, isActive: $showNavigation) {
//                    EmptyView()
//                }
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.5))
                    .frame(width: 94, height: 94)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 0) {
                        if let name = viewModel.name, let saves = viewModel.saves {
//                            Text("\(name)")
//                                .bold()
//                            //                        .font(.system(size: 24))
//                                .minimumScaleFactor(0.001)
//                            //                        .lineLimit(1)
//                                .padding(.trailing, 6)
                            
                            Group {
                                Image(systemName: "star.fill")
                                Text("\(viewModel.saves ?? 0)명이 저장")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        }
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
                }
            }
            .onTapGesture {
                print("Tapped \(showNavigation)")
                self.showNavigation = true
            }
        } else {
            ProgressView(style: UIActivityIndicatorView.Style.medium)
        }
    }
}
//
//struct LargePlaceCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LargePlaceCardView(of: PlaceInfo(document: OnePlaceResponse(identifier: <#T##String#>, name: <#T##String#>, x: <#T##String#>, y: <#T##String#>, phone: <#T##String?#>, address: <#T##String?#>, imageUrl: <#T##String?#>, category: <#T##String?#>, saves: <#T##Int?#>))
//    }
//}
