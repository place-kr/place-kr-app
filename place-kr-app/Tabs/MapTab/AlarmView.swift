//
//  AlarmView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/06/08.
//

import SwiftUI

struct AlarmView: View {
    @Environment(\.presentationMode) var presentation

    var body: some View {
        VStack {
            PageHeader(title: "알림",
                       leading: Image(systemName: "chevron.left"), leadingAction: { presentation.wrappedValue.dismiss() })
            .padding(.horizontal, 31)
            .padding(.vertical, 17)
            
            CustomDivider()
            
            EmptyHolderView(title: "아직 알림이 없어요", message: "새로운 소식이 들어오는대로 알려드릴게요!")
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct AlarmView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmView()
    }
}
