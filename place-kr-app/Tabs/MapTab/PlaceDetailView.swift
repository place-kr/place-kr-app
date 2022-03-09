//
//  PlaceDetailView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/08.
//

import SwiftUI
import Pages
import SwiftUIPager

class PlaceDetailViewModel: ObservableObject {
    @Published var images: [Image] = [Image("dog"), Image("dog"), Image("dog")]
}

struct PlaceDetailView: View {
    @Environment(\.presentationMode) var presentation
//    let placeInfo: PlaceInfo
    @ObservedObject var page: Page = .first()
    
    @State var index: Int = 0
    @ObservedObject var viewModel = PlaceDetailViewModel()
    
    var body: some View {
        VStack {
            Pager(page: page, data: viewModel.images.indices, id: \.self) {
                viewModel.images[$0]
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: 270)
                    .clipped()
            }
            .sensitivity(.high)
            
            Text("미나미")
            Text("포로리님의 플레이스")
            Categories
            
            Spacer()
            
            Button(action: {}) {
                Text("평가 남기기")
            }
        }
        .navigationBarTitle("플레이스 정보", displayMode: .inline)
        .navigationBarItems(leading:
                                Button(action: { self.presentation.wrappedValue.dismiss() },
                                       label: { Image(systemName: "chevron") }),
                            trailing:
                                HStack {
                                    Button(action: {}) { Image(systemName: "star.fill" )}
                                    Button(action: {}) { Image(systemName: "square.and.arrow.up") }
                                }
        )
    }
}

extension PlaceDetailView {
    var Categories: some View {
        let texts = ["일식", "깔끔해요", "아늑해요"]
        
        return HStack {
            Spacer()
            ForEach(texts, id: \.self) { text in
                Button(action: {}, label: {
                    Text(text)
                        .padding(.vertical, 8)
                })
                    .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, height: 20))
            }
            Spacer()
        }
    }
}

struct PlaceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetailView()
    }
}
