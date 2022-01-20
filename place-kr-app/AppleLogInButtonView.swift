//
//  AppleLogInButton.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/19.
//

import SwiftUI
import AuthenticationServices
import CoreData

final class SignInWithApple: UIViewRepresentable {
  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
    return ASAuthorizationAppleIDButton()
  }
  
  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
  }
}

struct AppleLogInButtonView: View {
    @Environment(\.window) var window: UIWindow?
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @State var appleSignInDelegates: SignInWithAppleDelegates! = nil

    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) var request: FetchedResults<UserProfile>

    var body: some View {
        SignInWithApple()
            .frame(width: 280, height: 60)
            .onTapGesture(perform: showAppleLogin)
    }
    
    // MARK: Generate the delegate and assign it to the class’ property.
    private func showAppleLogin() {
        // Generate the ASAuthorizationController as before, but this time, tell it to use your custom delegate class.
        // By calling performRequests(), you’re asking iOS to display the Sign In with Apple modal view.
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        performSignIn(using: [request])
    }
    
    private func performSignIn(using requests: [ASAuthorizationRequest]) {
        appleSignInDelegates = SignInWithAppleDelegates(window: window) { userData, success in
            if success {
                if let email = userData.email, let name = userData.name {
                    UserProfile.create(userId: userData.identifier, name: name.displayName(), email: email, using: viewContext)
                    print(userData)
                } else {
                    print("Already registered")
                    print(userData)
                }
            } else {
                print("Error while preparing Apple login")
                fatalError()
            }
        }
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = appleSignInDelegates
        controller.presentationContextProvider = appleSignInDelegates
        controller.performRequests()
    }
    
    private func performExistingAccountSetupFlows() {
    #if !targetEnvironment(simulator)
        let requests = [
            ASAuthorizationAppleIDProvider().createRequest()
            //      ASAuthorizationPasswordRequest.createRequest()
        ]
        performSignIn(using: requests)
    #endif
    }
}

// If you’re using the simulator, do nothing. The simulator will print out an error if you make these calls.
// Ask Apple to make requests for both Apple ID and iCloud keychain checks.
// Call your existing setup code.
struct AppleLogInButton_Previews: PreviewProvider {
    static var previews: some View {
        AppleLogInButtonView()
    }
}
