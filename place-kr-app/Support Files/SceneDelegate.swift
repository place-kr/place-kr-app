import UIKit
import SwiftUI
import NaverThirdPartyLogin
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        NaverThirdPartyLoginConnection
            .getSharedInstance()?
            .receiveAccessToken(URLContexts.first?.url)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                guard error == nil else {
                    print("Found an error \(error!.localizedDescription)")
                    return
                }
                if dynamicLink == dynamicLink {
                    //          self.handelIncomingDynamicLink(_dynamicLink: dynamicLink!)
                }
            }
            print(linkHandled)
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let userActivity = connectionOptions.userActivities.first {
          self.scene(scene, continue: userActivity)
        } else {
          self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let rootView =
            ContentView()
                .environment(\.window, window)

            window.rootViewController = UIHostingController(rootView: rootView)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        UINavigationBar.appearance().tintColor = UIColor.black
    }
}



