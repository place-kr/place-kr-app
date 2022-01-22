import SwiftUI
import CoreData

struct NaverLoginView: View {
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) var userProfile: FetchedResults<UserProfile>
    
    @Binding var success: Bool
    
    var body: some View {
        NaverVCRepresentable { userData in
            
            if isUserRegistered(userData) == NaverUserData.userType.notRegistered {
                UserProfile.create(userId: userData.id,
                                   name: userData.name,
                                   email: userData.email,
                                   using: viewContext)
            } else {
                print("Already Registered")
                print(userData.name)
            }
            
            success = true
        }
    }
    
    
    private func isUserRegistered(_ user :NaverUserData) -> NaverUserData.userType {
        // DB에 있는 유저인지 체크
        // TODO: 웹에서 처리할 것인지?
        let userID = user.id
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", "userId", userID)
        request.predicate = predicate
        
        do {
            let results = try viewContext.fetch(request)
            print(results.count)
            if results.isEmpty {
                return .notRegistered    // Not registered
            } else {
                return .registered     // Registered
            }
        } catch {
            fatalError("Error fetching user profile")
        }
    }
}

struct TestNaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NaverLoginView(success: .constant(false))
    }
}
