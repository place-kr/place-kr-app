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

extension NaverLoginButtonView {
    /// Returning token type and token
    var NaverLoginView: some View {
        NaverVCRepresentable { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let (tokenType, accessToken)):
                print("Successfully get token. Type:\(tokenType), Token:\(accessToken)")
                print(tokenType, accessToken)
            }
            self.success = true
        }
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
