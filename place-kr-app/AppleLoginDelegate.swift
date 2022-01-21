import UIKit
import AuthenticationServices

class AppleLoginDelegate: NSObject {
    private let completionHandler: (AppleUserData, Bool) -> Void
    private weak var window: UIWindow!
    
    init(window: UIWindow?, completion: @escaping (AppleUserData, Bool) -> Void) {
        self.window = window
        self.completionHandler = completion
    }
}

extension AppleLoginDelegate: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}

extension AppleLoginDelegate: ASAuthorizationControllerDelegate {
    // If you receive details, you know it’s a new registration.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            // Call registration method once you receive details.
            if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                registerNewAccount(credential: appleIdCredential)
            } else {    // Call existing account method if you don’t receive details.
                signInWithExistingAccount(credential: appleIdCredential)
            }
            break
        case let passwordCredential as ASPasswordCredential:
            // Using password credential
            break
        default:
            break
        }
    }
    
    // MARK: Save the desired details and the Apple-provided user in a struct.
    // Store the details into the iCloud keychain for later use.
    // Make a call to your service and signify to the caller whether registration succeeded or not.
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        let userData = AppleUserData(email: credential.email!, name: credential.fullName!, identifier: credential.user)
        self.completionHandler(userData, true)
        
        // MARK: Store in CoreData way
        
        // MARK: Store in KeyChain way
//        let keychain = UserDataKeychain()
//        do {
//            try keychain.store(userData)
//        } catch {
//            self.signInSucceeded(false)
//        }
        
//        do { // If you got web API, do stuffs in here
//            let success = try WebApi.Register(user: userData, identityToken: credential.identityToken, authorizationCode: credential.authorizationCode)
//            self.signInSucceeded(success)
//        } catch {
//            self.signInSucceeded(false)
//        }
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
        let userData = AppleUserData(email: nil, name: nil, identifier: credential.user)
        self.completionHandler(userData, true)
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        // if (WebAPI.login(credential.user, credential.password)) {
        //   ...
        // }
        // TODO: To be corrected
        let userData = AppleUserData(email: nil, name: nil, identifier: credential.user)
        self.completionHandler(userData, true)
    }
    
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
