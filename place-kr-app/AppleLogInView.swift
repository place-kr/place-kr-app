//
//  AppleLogInButton.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/19.
//

import SwiftUI
import AuthenticationServices


struct AppleLogInView: View {
    @EnvironmentObject var loginManger: LoginManager
    @ObservedObject var viewModel: AppleLoginViewModel
    @State var showWarning = false
    @State var warningContent = ""

    init(viewModel: AppleLoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        SignInWithApple()
            .alert(isPresented: $showWarning) {
                basicSystemAlert(title: "오류!", content: self.warningContent)
            }
            .onTapGesture {
                loginManger.status = .inProgress
                viewModel.showAppleLogin { result in
                    switch result {
                    case .success(_):
                        loginManger.socialAuthResultHandler(result)
                    case .failure(let error):
                        showWarning = true
                        warningContent = error.description
                    }
                }
            }
    }
}

extension AppleLogInView {
    final class SignInWithApple: UIViewRepresentable {
      func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton()
      }
      
      func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    }
}

// If you’re using the simulator, do nothing. The simulator will print out an error if you make these calls.
// Ask Apple to make requests for both Apple ID and iCloud keychain checks.
// Call your existing setup code.
//struct AppleLogInButton_Previews: PreviewProvider {
//    static var previews: some View {
//        AppleLogInButtonView(success: .constant(false))
//    }
//}
