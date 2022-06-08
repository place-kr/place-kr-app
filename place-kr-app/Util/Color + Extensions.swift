//
//  Color .swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/09.
//

import SwiftUI

func colorFrom(hex: String) -> ListColor {
    switch hex {
    case "fcf8f5":
        return .beige
    case "fff5bd":
        return .eggShell
    case "b9c6e8":
        return .lightBlueGrey
    case "f7d4bc":
        return .lightTan
    case "9fcae9":
        return .lightTeal
    case "e3e0ff":
        return .paleLilac
    case "c9f0fe":
        return .paleSkyBlue
    case "a5d6af":
        return .paleTeal
    case "facae5":
        return .veryLightPurple
    case "fec97f":
        return .wheat
    default:
        return .beige
    }
}

enum ListColor: String, CaseIterable {
    case beige
    case eggShell
    case lightBlueGrey
    case lightTan
    case lightTeal
    case paleLilac
    case paleSkyBlue
    case paleTeal
    case veryLightPurple
    case wheat
    
    var color: Color {
        return Color(self.rawValue)
    }
    
    var HEX: String {
        switch self {
        case .beige:
            return "fcf8f5"
        case .eggShell:
            return "fff5bd"
        case .lightBlueGrey:
            return "b9c6e8"
        case .lightTan:
            return "f7d4bc"
        case .lightTeal:
            return "9fcae9"
        case .paleLilac:
            return "e3e0ff"
        case .paleSkyBlue:
            return "c9f0fe"
        case .paleTeal:
            return "a5d6af"
        case .veryLightPurple:
            return "facae5"
        case .wheat:
            return "fec97f"
        }
    }
}

extension Color {
    public static let backgroundGray = Color("grayBackground")
    public static let naver = Color("naver")
    public static let placeHolderGray = Color("placeHolderGray")
}


