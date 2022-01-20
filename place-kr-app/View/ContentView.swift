//
//  ContentView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var showNaverLogin = false
    @Environment(\.window) var window: UIWindow?
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext

    var body: some View {
        VStack {
            Text("Temporary")
            Button(action: { showNaverLogin = true }) {
                Text("Naver로 로그인")
            }
            AppleLogInButtonView()
                .environment(\.window, window)
                .environment(\.managedObjectContext, viewContext)
            
            if showNaverLogin {
                NaverLoginView()
                    .frame(width: 0, height: 0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
