//
//  NoticeView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/06/08.
//

import SwiftUI

struct NoticeView: View {
    @Environment(\.presentationMode) var presentation

    var body: some View {
        VStack {
            PageHeader(title: "공지사항",
                       leading: Image(systemName: "chevron.left"), leadingAction: { presentation.wrappedValue.dismiss() })
            .padding(.horizontal, 31)
            .padding(.vertical, 17)
            
            CustomDivider()
            
            EmptyHolderView(title: "아직 공지사항이 없어요", message: "새로운 소식이 들어오면 알려드릴게요!")
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}
