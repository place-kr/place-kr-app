//
//  AppleLogInButton.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/19.
//

import SwiftUI
import AuthenticationServices


struct AppleLogInView: View {
    @ObservedObject var viewModel: AppleLoginViewModel
    @Binding var success: Bool

    init(viewModel: AppleLoginViewModel, success: Binding<Bool>) {
        self.viewModel = viewModel
        self._success = success
    }
    
    var body: some View {
        SignInWithApple()
            .onTapGesture {
                viewModel.showAppleLogin { success in
                    self.success = success
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
