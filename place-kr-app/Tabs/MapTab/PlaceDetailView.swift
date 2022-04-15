//
//  PlaceDetailView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/08.
//

import SwiftUI
import SwiftUIPager

class PlaceDetailViewModel: ObservableObject {
    @Published var placeInfo: PlaceInfo
    
    @Published var images: [Image] = [Image("dog"), Image("dog"), Image("dog")]
    @Published var messeages: [String] = [
        "아주 훌륭합니다",
        "매일매일 가고 싶은 곳",
        "플레이스에서 발견한 보물같은 맛집 매일가요",
        "아주 아주아주아주 좋아요",
        "아주 훌륭합니다",
        "아주 훌륭합니다"
    ]
    
    init(info placeInfo: PlaceInfo) {
        self.placeInfo = placeInfo
    }
}

struct PlaceDetailView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var page: Page = .first()
    @ObservedObject var viewModel: PlaceDetailViewModel
    
    @State var showEntireComments = false
    @State var showAddComment = false
    
    let placeInfo: PlaceInfo

    init(info placeInfo: PlaceInfo) {
        self.placeInfo = placeInfo
        self.viewModel = PlaceDetailViewModel(info: placeInfo)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 7) {
                VStack {
                    Pager(page: page, data: viewModel.images.indices, id: \.self) {
                        viewModel.images[$0]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 270)
                            .clipped()
                    }
                    .sensitivity(.high)
                    .frame(height: 270)
                    .padding(.bottom, 21)
                    
                    Text(placeInfo.name)
                        .font(.basic.bold21)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                        Text("포로리님의 플레이스")
                    }
                    .font(.basic.normal12)
                    
                    Categories
                    
                    InteractionButtons
                        .padding(.bottom, 10)
                }
                .background(Color.white)
                
                VStack(spacing: 12) {
                    PlaceInformations
                        .padding(.top, 12)
                    
                    Comments
                    

                    Spacer()
                    
                    LeaveCommentButton
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            
        }
        .showAlert(show: $showAddComment, alert: CommentAlertView(action: {
            withAnimation(.spring()) {
                self.showAddComment = false
            }
        }))
        .background(Color("grayBackground").edgesIgnoringSafeArea(.bottom))        .navigationBarTitle("플레이스 정보", displayMode: .inline)
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
    var LeaveCommentButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                self.showAddComment = true
            }
        }) {
            HStack {
                Spacer()
                Text("평가 남기기")
                    .font(.basic.light14)
                Spacer()
            }
        }
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, height: 52))
    }
    
    var PlaceInformations: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("플레이스 정보")
                .font(.basic.bold21)
                .padding(.bottom, 5)
            
            HStack {
                // TODO: 이미지 수정
                Image(systemName: "mappin")
                Text("서울 서초구 서초대로")
                Spacer()
            }
            .font(.basic.light14)
            
            HStack {
                Image(systemName: "phone.fill")
                Text("02-1234-5678")
                Spacer()
            }
            .font(.basic.light14)
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 21)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white))
    }
    
    var Comments: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("한줄 평")
                    .font(.basic.bold21)
                .padding(.bottom, 5)
                
                Spacer()
                
                Button(action: { showEntireComments = true }) {
                    Text("전체보기")

                }
                .foregroundColor(.black)
                .font(.basic.normal12)
            }
            .padding(.bottom, 12)
            
            ForEach(0..<min(3, viewModel.messeages.count), id: \.self) { idx in
                let message = viewModel.messeages[idx]
                Text(message)
                    .font(.basic.light14)
                    .padding(.vertical, 9)
                    .padding(.trailing, 12)
                    .padding(.leading, 17)
                    .background(
                        RoundedCorner(radius: 14,
                                      corners: [.topLeft, .topRight, .bottomRight])
                            .fill(Color.backgroundGray)
                    )
            }
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 21)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)                        .fill(Color.white))
    }
    
    var InteractionButtons: some View {
        HStack(spacing: 25) {
            Button(action: {}) {
                HStack(spacing: 9) {
                    StarButtonShape(15, fgColor: .gray, bgColor: .gray.opacity(0.3))
                    Text("123")
                        .font(.basic.normal12)
                        .foregroundColor(.black)
                }
            }
            
            Button(action: {}) {
                HStack(spacing: 9) {
                    StarButtonShape(15, fgColor: .gray, bgColor: .gray.opacity(0.3))
                    Text("공유하기")
                        .font(.basic.normal12)
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    var Categories: some View {
        let texts = ["일식", "깔끔해요", "아늑해요"]
        
        return HStack {
            Spacer()
            ForEach(texts, id: \.self) { text in
                Button(action: {}, label: {
                    Text(text)
                        .font(.basic.light11)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                })
                    .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: false, height: 20))
            }
            Spacer()
        }
    }
}
//
//struct PlaceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaceDetailView(info: <#PlaceInfo#>)
//    }
//}
