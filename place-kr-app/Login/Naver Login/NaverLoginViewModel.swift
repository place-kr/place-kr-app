//
//  NaverLoginViewModel.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/27.
//

import Foundation
import NaverThirdPartyLogin

class NaverLoginButtonViewModel: ObservableObject {
    
}

extension NaverLoginButtonViewModel {
    private struct NaverLoginRequestResponse: Codable {
        let token: String
        
        func getDescription() {
            print("Token: \(self.token)")
        }
    }
}
