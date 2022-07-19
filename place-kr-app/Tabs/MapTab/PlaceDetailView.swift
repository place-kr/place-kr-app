//
//  PlaceDetailView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/08.
//

import SwiftUI
import SwiftUIPager
import SDWebImageSwiftUI

struct ReviewBody: Encodable {
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
    }
}

struct ReviewResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Review]
      
    struct Review: Decodable, Identifiable {
        let id = UUID()
        let reviewer: Reviewer
        let content: String
        let date: String
        
        var parsedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            guard let localDate = formatter.date(from: self.date) else {
                return ""
            }
            
            let receivedComponents = Calendar.current.dateComponents([.year, .month, .day], from: localDate)
            
            let currentComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            
            // 날짜 -> 텍스트
            if receivedComponents.day! == currentComponents.day &&
                receivedComponents.month! == currentComponents.month &&
                receivedComponents.year! == currentComponents.year {
                return "오늘"
            }
            else if receivedComponents.weekOfYear == currentComponents.weekOfYear &&
                        receivedComponents.year == currentComponents.year {
                return "이번주"
            }
            else if receivedComponents.month == currentComponents.month &&
                        receivedComponents.year == currentComponents.year {
                return "이번달"
            }
            else {
                formatter.dateFormat = "yyyy.MM.dd"
                return formatter.string(from: localDate)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case reviewer, content
            case date = "date_created"
        }
        
        struct Reviewer: Decodable {
            let identifier: String
            let nickname: String
        }
    }
}

struct ReviewErrorBody: Decodable {
    let message: String
    let details: Detail
    
    struct Detail: Decodable {
        let ALREADY_REVIEWED: String?
    }
}

struct PlaceDetailView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var page: Page = .first()
    @ObservedObject var viewModel: PlaceDetailViewModel
    
    @State var showEntireComments = false
    @State var showAddComment = false
    @State var commentText = ""
    
    @State var showWarning = false
    @State var bodyType: AlertBody = .error
    @State var commentBodyType: CommentAlertBody = .new
    
    let placeInfo: PlaceInfo

    init(info placeInfo: PlaceInfo) {
        self.placeInfo = placeInfo
        self.viewModel = PlaceDetailViewModel(info: placeInfo)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: "플레이스 정보",
                       leading: Image(systemName: "chevron.left"), leadingAction: {presentation.wrappedValue.dismiss() },
                       firstTrailing: Image("roundedStar"), firstAction: {},
                       secondeTrailing: Image("shareLine"), secondAction: {
                bodyType = .notImplemented
                showWarning = true
            })
            .padding(.vertical, 17)
            .padding(.horizontal, 15)
            
            CustomDivider()
            
            ScrollView {
                VStack(spacing: 0) {
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
                    
                    // 플레이스 이름
                    Text(placeInfo.name)
                        .font(.basic.bold21)
                        .padding(.bottom, 8)
                    
                    // 기여자
                    HStack(spacing: 6) {
                        Image("contributorBlack")
                        Text("\(placeInfo.registrant)님의 플레이스")
                    }
                    .font(.basic.normal12)
                    .padding(.bottom, 8)
                    
                    // 카테고리 캡슐
                    // TODO: 수정
//                    Categories
//                        .padding(.bottom, 20)
                    
                    InteractionButtons
                        .padding(.bottom, 17)
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
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color("grayBackground").edgesIgnoringSafeArea(.bottom))
        }
        .showAlert(show: $showAddComment, alert: makeAlertBody(self.commentBodyType))
        .alert(isPresented: $showWarning) {
            self.makeAlertBody(self.bodyType)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)

    }
}

extension PlaceDetailView {
    enum AlertBody {
        case error
        case deleteConfirm(id: String)
        case notImplemented
        case duplicate
    }
    
    enum CommentAlertBody {
        case new
        case edit
    }
    
    func makeAlertBody(_ case: AlertBody) -> Alert {
        switch `case` {
        case .error:
            return basicSystemAlert
        case .deleteConfirm(let id):
            return Alert(title: Text("한줄평을 삭제하시겠어요?"),
                         primaryButton: .cancel(),
                         secondaryButton: .default(Text("Ok")) {
                viewModel.deleteReview(id: id) { result in
                    if result == false {
                        bodyType = .error
                        showWarning = true
                    }
                }
            })
        case .notImplemented:
            return basicSystemAlert(title: "해당 기능은 곧 추가될 예정입니다. 조금만 기다려주세요!", content: "")
        case .duplicate:
            return basicSystemAlert(title: "이미 작성된 리뷰가 존재합니다", content: "리뷰를 다시 작성하려면 수정하기를 이용해주세요")
        }
    }
    
    func makeAlertBody(_ case: CommentAlertBody) -> some View {
        switch `case` {
        case .new:
            return CommentAlertView(
                // MARK: - 입력완료 버튼
                text: $commentText,
                isEdit: false, action: {
                    viewModel.postReview(id: self.viewModel.placeInfo.id, comment: self.commentText) {
                        result in
                        // MARK: - 에러 패턴매칭
                        switch result {
                        case .success(()):
                            self.viewModel.getReviews(id: placeInfo.id, refresh: true)
                            break
                        case .failure(let error):
                            switch error {
                            case URLError.cancelled:
                                print("Duplicate")
                                self.bodyType = .duplicate
                                self.showWarning = true
                                break
                            default:
                                self.bodyType = .error
                                self.showWarning = true
                                break
                            }
                            self.commentText = ""
                        }
                    }
                    withAnimation(.spring()) {
                        self.showAddComment = false
                    }
                })
        case .edit:
            return CommentAlertView(
                // MARK: - 입력완료 버튼
                text: $commentText, isEdit: true,
                action: {
                    viewModel.editReview(id: self.viewModel.placeInfo.id, comment: self.commentText) {
                        result in
                        // MARK: - 에러 패턴매칭
                        switch result {
                        case true:
                            self.viewModel.getReviews(id: placeInfo.id, refresh: true)
                            break
                        case false:
                            self.bodyType = .error
                            self.showWarning = true
                            break
                        }
                        
                        self.commentText = ""
                    }
                withAnimation(.spring()) {
                    self.showAddComment = false
                }
            })
        }
    }
    
    var LeaveCommentButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                self.showAddComment = true
            }
            self.commentBodyType = .new
        }) {
            HStack {
                Spacer()
                Text("평가 남기기")
                    .font(.basic.normal14)
                Spacer()
            }
        }
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, cornerRadius: 10, height: 52))
    }
    
    var PlaceInformations: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("플레이스 정보")
                .font(.basic.bold21)
                .padding(.bottom, 11)
            
            HStack {
                Image("infoAddress")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 16)
                
                Text(placeInfo.address)
                    .font(.basic.normal14)
                Spacer()
            }
            .padding(.bottom, 7)
            
            HStack {
                Image(systemName: "phone.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                Text(placeInfo.phone)
                    .font(.basic.normal14)
                Spacer()
            }
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
                Text("한줄평")
                    .font(.basic.bold21)
                .padding(.bottom, 5)
                
                Spacer()
            }
            .padding(.bottom, 12)
            
            if viewModel.reviews.isEmpty {
                HStack {
                    if viewModel.progress == .inProcess {
                        HStack {
                            Spacer()
                            CustomProgressView
                            Spacer()
                        }
                    } else {
                        Spacer()
                        Text("리뷰를 남긴 사람이 없습니다.\n직접 리뷰를 남겨보세요!")
                            .multilineTextAlignment(.center)
                            .font(.basic.normal14)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom, 20)
                        Spacer()
                    }
                }
            } else {
                ForEach(viewModel.reviews) { review in
                    VStack(alignment: .leading) {
                        Text(review.content)
                            .font(.basic.normal14)
                        
                        
                        HStack {
                            Text(review.reviewer.nickname)
                                .font(.basic.normal12)
                            
                            Text(review.parsedDate)
                                .font(.basic.normal12)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            // TODO: Update here
                            if review.reviewer.nickname == UserInfoManager.userName {
                                EditAndDeleteButtons(id: self.viewModel.placeInfo.id)
                            }
                        }
                    }
                    .padding(.vertical, 9)
                    .padding(.trailing, 12)
                    .padding(.leading, 17)
                    .background(
                        RoundedCorner(radius: 14,
                                      corners: [.topLeft, .topRight, .bottomRight])
                        .fill(Color.backgroundGray)
                    )
                }
                
                HStack {
                    Spacer()
                    if viewModel.progress == .inProcess {
                        ProgressView(style: .medium)
                    }
                    
                    if let nextPageUrl = viewModel.nextPage {
                        Button(action: {
                            viewModel.getReviews(id: viewModel.placeInfo.id,
                                                 nextUrl: nextPageUrl)
                            viewModel.nextPage = nil
                        }) {
                            Text("+ 더 보기")
                        }
                        .foregroundColor(.gray.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 21)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white))
    }
    
    // MARK: 삭제 수정 버튼
    func EditAndDeleteButtons(id: String) -> some View {
        return HStack(spacing: 2.5) {
            Button(action: {
                withAnimation(.spring()) {
                    showAddComment = true
                }
                self.commentBodyType = .edit
            }) {
                Text("수정")
            }
            .font(.basic.bold10)
            
            Text("ㅣ")
            
            Button(action: {
                // 삭제 확인 얼러트 띄우기
                bodyType = .deleteConfirm(id: id)
                showWarning = true
            }) {
                Text("삭제")
            }
            .font(.basic.bold10)
        }
        .foregroundColor(.gray.opacity(0.5))
    }
    
    var InteractionButtons: some View {
        HStack(spacing: 25) {
            Button(action: {}) {
                HStack(spacing: 9) {
                    Image(placeInfo.isFavorite ? "placeAdded" : "addedCount")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 27, height: 27)
                    
                    Text("\(viewModel.placeInfo.saves)")
                        .font(.basic.normal12)
                        .foregroundColor(.black)
                }
            }
            
            Button(action: {
                bodyType = .notImplemented
                showWarning = true
            }) {
                HStack(spacing: 9) {
                    Image("share")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 27, height: 27)
                    
                    Text("공유하기")
                        .font(.basic.normal12)
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    var Categories: some View {
        // !!!: UNCOMMENT WHENENVER
        let texts = ["일식", "깔끔해요", "아늑해요"]
//        let texts = [""]
        return HStack {
            Spacer()
            ForEach(texts, id: \.self) { text in
                Button(action: {}, label: {
                    Text(text)
                        .font(.basic.normal12)
                        .padding(.vertical, 4)
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
