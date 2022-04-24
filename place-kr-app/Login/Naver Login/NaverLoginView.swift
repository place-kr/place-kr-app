import SwiftUI
import CoreData

struct NaverLoginButtonView: View {
    @State var showNaverLogin = false
    @ObservedObject var viewModel = NaverLoginButtonViewModel()
    @EnvironmentObject var loginManager: LoginManager
    
    @State var showWarning = false
    @State var warningContent = ""

    var body: some View {
        Button(action: {
//            showNaverLogin = true
//            print(showNaverLogin)
            NaverVCRepresentable.loginInstance?.requestThirdPartyLogin()
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
        .alert(isPresented: $showWarning) {
            basicSystemAlert(title: "오류 발생", content: warningContent)
        }
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.black)
        )
//                .fill(Color("naver")))
        .foregroundColor(.white)
        
//        if showNaverLogin {
            NaverLoginView
                .frame(width: 0, height: 0)
//        }
    }
}

extension NaverLoginButtonView {
    /// Login modal view
    var NaverLoginView: some View {
        NaverVCRepresentable { result in
            switch result {
            case .failure(let error):
                self.warningContent = error.description + "\n개발진에게 문의 부탁드립니다."
                self.showWarning = true
            default:
                loginManager.socialAuthResultHandler(result)
            }
        }
    }
}

struct NaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NaverLoginButtonView()
    }
}
