import SwiftUI
import CoreData

struct NaverLoginButtonView: View {
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) var userProfile: FetchedResults<UserProfile>
    
    @Binding var success: Bool
    @State var showNaverLogin = false

    var body: some View {
        
        Button(action: { showNaverLogin = true }) {
            Text("Naver로 로그인")
                .font(.system(size: 20))
        }
        .foregroundColor(.white)
        
        if showNaverLogin {
            NaverLoginView
        }
    }
}

class NaverLoginButtonViewModel: ObservableObject {
    
}

extension NaverLoginButtonView {
    private struct NaverLoginRequestResponse: Codable {
        let token: String
        
        func getDescription() {
            print("Token: \(self.token)")
        }
    }
    
    /// Returning token type and token
    var NaverLoginView: some View {
        NaverVCRepresentable { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let userInfo):
                print("Successfully get token. Email:\(userInfo.email), Token:\(userInfo.accessToken)")
                
                let url = URL(string: "https://dev.place.tk/api/v1/auth/naver")!
                let encoder = JSONEncoder()
                guard let body = try? encoder.encode(userInfo) else {
                    print("Error while encoding")
                    // TODO: Error handle
                    return
                }

                self.sendPostRequest(to: url, body: body) { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let result):
                        print(result)
                    }
                }
                
            }
            self.success = true
        }
    }
    
    private func sendPostRequest(to url: URL, body: Data, then handler: @escaping (Result<Data, Error>) -> Void) {
        let completionHandler = handler
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Error while uploading")
                completionHandler(.failure(error))
                return
            }

            print(response as Any)
            if let response = response {
                print(response)
            }

            guard let data = data else {
                completionHandler(.failure(URLError.self as! Error))
                print("Error in data")
                return
            }

            print(String(data: data, encoding: String.Encoding.utf8) as Any)
            let decoder = JSONDecoder()
            guard let jsonData = try? decoder.decode(NaverLoginRequestResponse.self, from: data) else {
                print("Error in parsing")
                return
            }
            print(jsonData.getDescription())
        }
        task.resume()
            
    }
    
//    /// Returning Userdata
//    var NaverLoginView: some View {
//        NaverVCRepresentable { userData in
//            if isUserRegistered(userData) == NaverUserData.userType.notRegistered {
//                UserProfile.create(userId: userData.id,
//                                   name: userData.name,
//                                   email: userData.email,
//                                   using: viewContext)
//            } else {
//                print("Already Registered")
//                print(userData.name)
//            }
//
//            success = true
//        }
//    }
    
//    private func isUserRegistered(_ user :NaverUserData) -> NaverUserData.userType {
//        // DB에 있는 유저인지 체크
//        // TODO: 웹에서 처리할 것인지?
//        let userID = user.id
//        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
//        let predicate = NSPredicate(format: "%K == %@", "userId", userID)
//        request.predicate = predicate
//
//        do {
//            let results = try viewContext.fetch(request)
//            print(results.count)
//            if results.isEmpty {
//                return .notRegistered
//            } else {
//                return .registered
//            }
//        } catch {
//            fatalError("Error while fetching user's profile")
//        }
//    }
}

struct NaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NaverLoginButtonView(success: .constant(false))
    }
}
