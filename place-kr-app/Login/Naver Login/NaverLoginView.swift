import SwiftUI
import CoreData

struct NaverLoginButtonView: View {
    @State var showNaverLogin = false
    @ObservedObject var viewModel = NaverLoginButtonViewModel()
    @EnvironmentObject var loginManager: LoginManager

    var body: some View {
        Button(action: {
            showNaverLogin = true
//            loginManager.status = .inProgress
        }) {
            HStack {
                Spacer()
                Image("naver")
                Text("Naver로 시작하기")
                    .font(.system(size: 20))
                Spacer()
            }
        }
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.black)
        )
//                .fill(Color("naver")))
        .foregroundColor(.white)
        
        if showNaverLogin {
            NaverLoginView
                .frame(width: 0, height: 0)
        }
    }
}

extension NaverLoginButtonView {
    /// Login modal view
    var NaverLoginView: some View {
        NaverVCRepresentable { result in
            loginManager.socialAuthResultHandler(result)
        }
    }
}

struct NaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NaverLoginButtonView()
    }
}
