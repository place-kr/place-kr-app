import SwiftUI
import CoreData

struct NaverLoginButtonView: View {
    @Binding var success: Bool
    @State var showNaverLogin = false
    @ObservedObject var viewModel = NaverLoginButtonViewModel()

    var body: some View {
        Button(action: { showNaverLogin = true }) {
            HStack {
                Spacer()
                Image("naver")
                Text("Naver로 로그인")
                    .font(.system(size: 20))
                Spacer()
            }
        }
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color("naver")))
        .foregroundColor(.white)
        
        if showNaverLogin {
            NaverLoginView
                .frame(width: 0, height: 0)
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
