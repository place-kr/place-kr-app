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
    
    @State var showNaverLogin = false
    @Binding var success: Bool
    

    var body: some View {
            VStack {
                Image(systemName: "shareplay")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150, alignment: .center)
                    .padding(.bottom)
                
                NaverLoginButtonView
                    .frame(width: 280, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black))
                 
                AppleLogInButtonView(success: $success)
                    .disabled(showNaverLogin)
                    .frame(width: 280, height: 60)
                    .environment(\.window, window)
                    .environment(\.managedObjectContext, viewContext)
                
                if showNaverLogin {
                    NaverLoginView(success: $success)
                        .frame(width: 0, height: 0)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
    }
    
    var NaverLoginButtonView: some View {
        Button(action: { showNaverLogin = true }) {
            Text("Naver로 로그인")
                .font(.system(size: 20))
        }
        .foregroundColor(.white)
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(success: .constant(false))
    }
}
