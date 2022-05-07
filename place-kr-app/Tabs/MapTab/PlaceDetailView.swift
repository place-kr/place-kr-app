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
        let id: String
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
            case id = "identifier"
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

class PlaceDetailViewModel: ObservableObject {
    typealias Review = ReviewResponse.Review
    
    @Published var placeInfo: PlaceInfo
    @Published var progress: Progress = .ready
    
    @Published var images: [Image] = [Image("dog"), Image("dog"), Image("dog")]
    @Published var reviews = [Review]()
    
    var nextPage: URL?
    
    /// id: Place ID
    func getReviews(id: String, nextUrl: URL? = nil, refresh: Bool = false) {
        self.progress = .inProcess
        
        var request: URLRequest? = nil
        if let url = nextUrl {
            request = PlaceSearchManager.authorizedRequest(url: "https" + String(Array(url.absoluteString)[4...]))
        } else {
            request = PlaceSearchManager.authorizedRequest(url: "https://dev.place.tk/api/v1/places/\(id)/reviews?limit=5")
        }
        
        guard var request = request else {
            self.progress = .failed
            return
        }

        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.progress = .failedWithError(error: error)
                }
                print(error)
            }
            
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                    default:
                        self.progress = .failed
                    }
                }
            }
            
            if let data = data {
                if let decoded = try? JSONDecoder().decode(ReviewResponse.self, from: data) {
                    DispatchQueue.main.async {
                        let reviews = decoded.results
                        if refresh {
                            self.reviews = reviews
                        } else {
                            self.reviews.append(contentsOf: reviews)
                        }
                        
                        if let nextPageString = decoded.next {
                            guard let url = URL(string: nextPageString) else { return }
                            self.nextPage = url
                        }
                        
                    }
                }
            }
        }
        .resume()
    }
    /// id: Place id
    func deleteReview(id: String, completion: @escaping (Bool) -> Void) {
        self.progress = .inProcess

        guard let request = authorizedRequest(method: "DELETE", api: "/me/places/\(id)/review") else {
            completion(false)
            return
        }
        
        guard let userName = UserInfoManager.userName else {
            completion(false)
            return
        }
                    
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.progress = .failedWithError(error: error)
                    completion(false)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                        let index = self.reviews.firstIndex{ $0.reviewer.nickname == userName }! // TODO: Change to ID later
                        self.reviews.remove(at: index)
                        
                        completion(true)
                    default:
                        self.progress = .failed
                        
                        // 에러 바디 확인
                        if let data = data, let decoded = try? JSONDecoder().decode(ErrorBody.self, from: data)  {
                            print(decoded)
                        }
                        
                        completion(false)
                    }
                }
            }
        }
        .resume()
    }
    
    /// id: Place id, comment: 새 코멘트
    func postReview(id: String, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.progress = .inProcess
        
        guard let request = authorizedRequest(method: "POST", api: "/me/places/\(id)/review", body: ReviewBody(content: comment)) else {
            completion(.failure(URLError(.badURL)))
            return
        }
                    
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.progress = .failedWithError(error: error)
                    completion(.failure(URLError(.unknown)))
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                        completion(.success(()))
                    default:
                        print(response)
                        self.progress = .failed
                        
                        // 에러 바디 확인
                        if let data = data,
                            let decoded = try? JSONDecoder().decode(ReviewErrorBody.self, from: data) {
                            print(String(decoding: data, as: UTF8.self))
                            if decoded.details.ALREADY_REVIEWED != nil {
                                completion(.failure(URLError(.cancelled)))
                                return
                            }
                        }
                        
                        completion(.failure(URLError(.unknown)))
                    }
                }
            }
        }
        .resume()
    }
    
    /// id: Place id, comment: 수정할 코멘트
    func editReview(id: String, comment: String, completion: @escaping (Bool) -> Void) {
        self.progress = .inProcess

        let body = ReviewBody(content: comment)
        guard let request = authorizedRequest(method: "PUT", api: "/me/places/\(id)/review", body: body) else {
            completion(false)
            return
        }
        
        guard let userName = UserInfoManager.userName else {
            completion(false)
            return
        }
                    
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.progress = .failedWithError(error: error)
                    completion(false)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
                        let index = self.reviews.firstIndex{ $0.reviewer.nickname == userName }! // TODO: Change to ID later
                        self.reviews.remove(at: index)
                        
                        completion(true)
                    default:
                        self.progress = .failed
                        
                        // 에러 바디 확인
                        if let data = data, let decoded = try? JSONDecoder().decode(ReviewErrorBody.self, from: data)  {
                            print(String(decoding: data, as: UTF8.self))
                            print(decoded)
                        }
                        
                        completion(false)
                    }
                }
            }
        }
        .resume()
    }
    
    init(info placeInfo: PlaceInfo) {
        self.placeInfo = placeInfo
        self.getReviews(id: placeInfo.id)
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
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, height: 52))
    }
    
    var PlaceInformations: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("플레이스 정보")
                .font(.basic.bold21)
                .padding(.bottom, 5)
            
            HStack {
                Image("infoAddress")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 16)
                
                Text(placeInfo.address)
                    .font(.basic.normal14)
                Spacer()
            }
            
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
                    Image("placeAdded")
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
        let texts = ["일식", "깔끔해요", "아늑해요"]
        
        return HStack {
            Spacer()
            ForEach(texts, id: \.self) { text in
                Button(action: {}, label: {
                    Text(text)
                        .font(.basic.normal12)
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
