//
//  NotificationView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/10.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "bell")
                .font(.basic.bold20)
                .frame(width: 50, height: 50)
                .foregroundColor(.black)
                .background(Circle().fill(.white))
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
