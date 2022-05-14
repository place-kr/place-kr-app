//
//  ToastAlert.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/05/14.
//

import SwiftUI

struct ToastAlert: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.basic.bold14)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .foregroundColor(.white)
            .background(
                Capsule().fill(.black)
            )
    }
}

struct ToastAlert_Previews: PreviewProvider {
    static var previews: some View {
        ToastAlert(text: "리스트 등록 완료!")
    }
}
