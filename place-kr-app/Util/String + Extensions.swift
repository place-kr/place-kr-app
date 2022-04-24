//
//  String + Extensions.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/24.
//

import SwiftUI

extension String {
    func onlyEmoji() -> String {
        return self.filter({$0.isEmoji})
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}
