//
//  PlaceDetailView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/08.
//

import SwiftUI
import SwiftUIPager

struct ReviewBody: Encodable {
    let reviewer: String
    let content: String
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
            

            if receivedComponents.day! == currentComponents.day &&
                receivedComponents.month! == currentComponents.month &&
                receivedComponents.year! == currentComponents.year {
                return "오늘"
            }
            else if receivedComponents.month == currentComponents.month &&
                        receivedComponents.year == currentComponents.year {
                return "이번주"
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

class PlaceDetailViewModel: ObservableObject {
    typealias Review = ReviewResponse.Review
    
    @Published var placeInfo: PlaceInfo
    @Published var progress: Progress = .ready
    
    @Published var images: [Image] = [Image("dog"), Image("dog"), Image("dog")]
    @Published var reviews = [Review]()
    
    func getReviews(id: String) {
        guard var request = PlaceSearchManager.authorizedRequest(url: "https://dev.place.tk/api/v1/places/\(id)/reviews") else {
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
                        self.reviews = reviews
                    }
                }
            }
        }
        .resume()
    }
    
    func postReview(id: String , comment: String, completion: @escaping (Bool) -> Void) {
        guard var request = PlaceSearchManager.authorizedRequest(url: "https://dev.place.tk/api/v1/places/\(id)/reviews") else {
            self.progress = .failed
            completion(false)
            return
        }
                
        let body = ReviewBody(reviewer: "Mock user", content: comment)
        guard let encoded = try? JSONEncoder().encode(body) else {
            self.progress = .failed
            completion(false)
            return
        }
        
        print(body)
        
        request.httpBody = encoded
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.progress = .inProcess
                
                if let error = error {
                    self.progress = .failedWithError(error: error)
                    completion(false)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print(response)
                    switch response.statusCode {
                    case (200..<300):
                        self.progress = .finished
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
                .overlay(
                    Group{ if viewModel.progress == .inProcess {
                        ProgressView(style: .medium)
                    }}
                )
                
            }
            
        }
        .showAlert(show: $showAddComment, alert: CommentAlertView(
            text: $commentText,
            action: {
                viewModel.postReview(id: self.viewModel.placeInfo.id, comment: self.commentText) { result in
                    switch result {
                    case true:
                        self.viewModel.getReviews(id: placeInfo.id)
                        self.showAddComment = false
                        break
                    case false:
                        self.showWarning = true
                        self.showAddComment = false
                        break
                    }
                    
                    self.commentText = ""
                }
            
            withAnimation(.spring()) {
                self.showAddComment = false
            }
        }))
        .alert(isPresented: $showWarning) {
            Alert(title: Text("알 수 없는 오류 발생"), message: Text("잠시 후 다시 시도해주세요."))
        }
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
                Text(placeInfo.address)
                Spacer()
            }
            .font(.basic.normal14)
            
            HStack {
                Image(systemName: "phone.fill")
                Text(placeInfo.phone)
                Spacer()
            }
            .font(.basic.normal14)
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
            }
            .padding(.bottom, 12)
            
            if viewModel.reviews.isEmpty {
                HStack {
                    Spacer()
                    Text("리뷰를 남긴 사람이 없습니다.\n직접 리뷰를 남겨보세요!\n-임시로 만들었는데 디자인 수정 사항 말씀해주세요-")
                        .multilineTextAlignment(.center)
                        .font(.basic.normal14)
                        .foregroundColor(.gray.opacity(0.5))
                    Spacer()
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
            }
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 21)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white))
    }
    
    var InteractionButtons: some View {
        HStack(spacing: 25) {
            Button(action: {}) {
                HStack(spacing: 9) {
                    Image("placeAdded")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 27, height: 27)
                    
                    Text("123")
                        .font(.basic.normal12)
                        .foregroundColor(.black)
                }
            }
            
            Button(action: {}) {
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
