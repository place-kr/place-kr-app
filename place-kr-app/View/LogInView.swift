//
//  LogInView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/22.
//

import SwiftUI
import CoreData
import Combine

struct LogInView: View {
    @Environment(\.window) var window: UIWindow?
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) var userProfile: FetchedResults<UserProfile>
    
    @Binding var success: Bool
    
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            RoundedRectangle(cornerRadius: 21)
                .fill(.gray.opacity(0.5))
                .frame(width: 125, height: 125)
                .padding(.bottom, 22)
            
            Text("MYPLACE")
                .font(.system(size: 27))
                .padding(.bottom, 12)
            
            Text("나만의 플레이스 만들기")
                .font(.system(size: 12))
                .padding(.bottom, 95)
            
            NaverLoginButtonView(success: $success)
                .frame(width: 320, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.black))
                .padding(.bottom, 14)
            
            AppleLogInButtonView(success: $success)
                .frame(width: 320, height: 54)
                .environment(\.window, window)
                .environment(\.managedObjectContext, viewContext)
            
            Spacer()
            HStack {
                Text("개인정보처리방침")
                    .font(.system(size: 12))
                Text("이용약관")
                    .font(.system(size: 12))
            }

        }
    }
    
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(success: .constant(false))
    }
}
