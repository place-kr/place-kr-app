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
    @Published var name: String
    @Published var saves: Int
    
    init(info: PlaceInfo) {
        self.name = info.name
        self.saves = info.saves
        self.placeInfo = info
    }
}

struct LargePlaceCardView: View {
    @ObservedObject var viewModel: LargePlaceCardViewModel
    @State var showNavigation = false
    
    init(of placeInfo: PlaceInfo) {
        self.viewModel = LargePlaceCardViewModel(info: placeInfo)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            // 여기로 네비게이션
            NavigationLink(
                destination: LazyView {
                    PlaceDetailView(info: viewModel.placeInfo)
                },
                isActive: $showNavigation) {
                    EmptyView()
                }
            
            /// 프로필 사진
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.5))
                .frame(width: 94, height: 94)
                .padding(.trailing, 20)
                        
            /// 텍스트 콘텐츠들
            VStack(alignment: .leading, spacing: 0) {
                // 이름, 저장 수
                Saves
                
                // 저장한 사람
                SavedByWhom
                
                // 카테고리
                Categories
                
            }
            
            Spacer()
        }
        .onTapGesture {
            print("Tapped \(showNavigation)")
            self.showNavigation = true
        }
    }
}

extension LargePlaceCardView {
    var Saves: some View {
        /// 저장 수
        HStack(alignment: .bottom, spacing: 0) {
            Group {
                Image(systemName: "star.fill")
                Text("\(viewModel.saves)명이 저장")
            }
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
        .padding(.bottom, 4)
    }
    
    var SavedByWhom: some View {
        /// 저장한 사람
        HStack(alignment: .center, spacing: 6) {
            Group {
                Image(systemName: "person.fill")
                Text("포로리님의 플레이스")
            }
            .font(.system(size: 12))
        }
        .padding(.bottom, 20)
    }
    
    /// 카테고리
    var Categories: some View {
        HStack(spacing: 5) {
            Text("일식")
                .encapsulate()
            Text("아늑해요")
                .encapsulate()
            Text("깔끔해요")
                .encapsulate()
        }
    }
}


//
//struct LargePlaceCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LargePlaceCardView(of: PlaceInfo(document: OnePlaceResponse(identifier: <#T##String#>, name: <#T##String#>, x: <#T##String#>, y: <#T##String#>, phone: <#T##String?#>, address: <#T##String?#>, imageUrl: <#T##String?#>, category: <#T##String?#>, saves: <#T##Int?#>))
//    }
//}
