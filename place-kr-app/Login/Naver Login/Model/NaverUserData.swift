import SwiftUI

struct NaverUserData: Codable {
    enum userType {
        case registered
        case notRegistered
    }
    
    let id: String          /// 동일인 식별 정보 - 동일인 식별 정보는 네이버 아이디마다 고유하게 발급되는 값
    let name: String        /// 사용자 이름
    let email: String       /// 사용자 메일 주소
    let nickname: String?   /// 사용자 별명
    let gender: String?     /// F: 여성 M: 남성 U: 확인불가
    let age: String?        /// 사용자 연령대
    let birthday: String?   /// 사용자 생일(MM-DD 형식)
    let profile_image: String?      /// 사용자 프로필 사진 URL
}
