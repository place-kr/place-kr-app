import UIKit
import AuthenticationServices


enum AppleLoginError: Error, CustomStringConvertible {
    case expiredToken
    case invalidResponse
    case fetch
    case userCancelled

    var description: String {
        switch self {
        case .expiredToken:
            return "토큰이 만료되었습니다."
        case .invalidResponse:
            return "네트워크에서 데이터를 불러오는 과정에서 에러가 발생했습니다."
        case .fetch:
            return "유저 데이터를 불러오는 과정에서 에러가 발생했습니다."
        case .userCancelled:
            return "로그인이 비정상적으로 취소되었습니다. 다시 시도해주세요."
        }
    }
}

class AppleLoginDelegate: NSObject {
    private let completionHandler: (Result<AppleUserData, AppleLoginError>) -> Void
    private weak var window: UIWindow!
    
    init(window: UIWindow?, completion: @escaping (Result<AppleUserData, AppleLoginError>) -> Void) {
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
        default:
            break
        }
    }
    
    // MARK: Save the desired details and the Apple-provided user in a struct.
    // Store the details into the iCloud keychain for later use.
    // Make a call to your service and signify to the caller whether registration succeeded or not.
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        let userData = AppleUserData(email: credential.email!, name: credential.fullName!, identifier: credential.user, identityToken: String(decoding: credential.identityToken!, as: UTF8.self), authCode: String(decoding: credential.authorizationCode!, as: UTF8.self))
        
        self.completionHandler(.success(userData))
    }
    
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        let userData = AppleUserData(email: credential.email, name: credential.fullName, identifier: credential.user, identityToken: String(decoding: credential.identityToken!, as: UTF8.self), authCode: String(decoding: credential.authorizationCode!, as: UTF8.self))
        self.completionHandler(.success(userData))

    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("[AppleLoginDelegate] \(error)")
        completionHandler(.failure(.userCancelled))
        // Handle error.
    }
}
