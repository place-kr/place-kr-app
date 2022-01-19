import UIKit
import AuthenticationServices

class SignInWithAppleDelegates: NSObject {
  private let signInSucceeded: (Bool) -> Void
  private weak var window: UIWindow!
  
  init(window: UIWindow?, onSignedIn: @escaping (Bool) -> Void) {
    self.window = window
    self.signInSucceeded = onSignedIn
  }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.window
  }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
  // Save the desired details and the Apple-provided user in a struct.
  // Store the details into the iCloud keychain for later use.
  // Make a call to your service and signify to the caller whether registration succeeded or not.
  private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
    let userData = UserData(email: credential.email!, name: credential.fullName!, identifier: credential.user)
    
    let keychain = UserDataKeychain()
    do {
      try keychain.store(userData)
    } catch {
      self.signInSucceeded(false)
    }
    
    do {
      let success = try WebApi.Register(user: userData, identityToken: credential.identityToken, authorizationCode: credential.authorizationCode)
      self.signInSucceeded(success)
    } catch {
      self.signInSucceeded(false)
    }
  }
  
  private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
    // You *should* have a fully registered account here.  If you get back an error
    // from your server that the account doesn't exist, you can look in the keychain
    // for the credentials and rerun setup
    // if (WebAPI.login(credential.user,
    //                  credential.identityToken,
    //                  credential.authorizationCode)) {
    //   ...
    // }
    self.signInSucceeded(true)
  }
  
  private func signInWithUserAndPassword(credential: ASPasswordCredential) {
    // if (WebAPI.login(credential.user, credential.password)) {
    //   ...
    // }
    self.signInSucceeded(true)
  }

  
  // If you receive details, you know it’s a new registration.
  // Call your registration method once you receive details.
  // Call your existing account method if you don’t receive details.
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let appleIdCredential as ASAuthorizationAppleIDCredential:
      if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
        registerNewAccount(credential: appleIdCredential)
      } else {
        signInWithExistingAccount(credential: appleIdCredential)
      }
      break
      
    case let passwordCredential as ASPasswordCredential:
      
      break
      
    default:
      break
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
  }
}
