//
//  Progress.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/13.
//

import Foundation

// 네트워크 진행 상황 표시
enum Progress {
    case ready
    case inProcess
    case finished
    case failed
    case failedWithError(error: Error)
}

extension Progress: Equatable {
    static func == (lhs: Progress, rhs: Progress) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready), (.inProcess, .inProcess), (.finished, .finished), (.failed, .failed), (.failedWithError, .failedWithError):
            return true
        default:
            return false
        }
    }
}
