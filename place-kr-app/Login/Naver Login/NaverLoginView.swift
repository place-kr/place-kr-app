import SwiftUI
import CoreData

struct NaverLoginButtonView: View {
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) var userProfile: FetchedResults<UserProfile>
    
    @Binding var success: Bool
    @State var showNaverLogin = false
    @ObservedObject var viewModel = NaverLoginButtonViewModel()

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
    /// Login pop up
    var NaverLoginView: some View {
        NaverVCRepresentable { result in
            self.success = viewModel.completionHandler(result)
        }
    }
}

struct NaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NaverLoginButtonView(success: .constant(false))
    }
}
