import UIKit
import NaverThirdPartyLogin
import NMapsMap

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: -네이버맵 SDK 인스턴스 생성
        NMFAuthManager.shared().clientId = "gutse7wfn1"
        
        
        // MARK: -네이버로그인 SDK 인스턴스 호출
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else {
            fatalError("Error occured while preparing NAVER login")
        }
        
        ///  네이버앱으로 로그인
        instance.isNaverAppOauthEnable = true
        /// 사파리로 로그인
        instance.isInAppOauthEnable = true
        
        // 인증 화면을 iPhone의 세로 모드에서만 사용하기
        instance.isOnlyPortraitSupportedInIphone()
        
        // 네이버 아이디로 로그인하기 설정
        instance.serviceUrlScheme = kServiceAppUrlScheme // 앱을 등록할 때 입력한 URL Scheme
        instance.consumerKey = kConsumerKey // 상수 - client id
        instance.consumerSecret = kConsumerSecret // pw
        instance.appName = kServiceAppName // app name
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let scheme = url.scheme else { return true }
        
        print("@#$@#$", scheme)

        if scheme.contains("naverlogin") {
            let result = NaverThirdPartyLoginConnection.getSharedInstance().receiveAccessToken(url)
            if result == CANCELBYUSER {
                print("result: \(result)")
            }
            return true
        }
        print("Naver login: Failed by unexpected reason")
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
