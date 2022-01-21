import SwiftUI
import CoreData

struct NaverLoginView: View {
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) var userProfile: FetchedResults<UserProfile>
    
    var body: some View {
        NaverVCRepresentable { userData, success in
            if success {
                guard let userData = userData else {
                    return
                }
                UserProfile.create(userId: userData.id,
                                   name: userData.name,
                                   email: userData.email,
                                   using: viewContext)
                print(userProfile)
            }
        }
    }
}

struct TestNaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NaverLoginView()
    }
}
