//
//  ContentView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/18.
//

import SwiftUI
import CoreData
import Combine


struct ContentView: View {
    @State var showNaverLogin = false
    @Environment(\.window) var window: UIWindow?
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) var userProfile: FetchedResults<UserProfile>

    // MARK: DEBUG vars
    @State var showingAlert = false
    
    var body: some View {
        VStack {
            Text("Temporary")
            Button(action: { showNaverLogin = true }) {
                Text("Naver로 로그인")
            }
            AppleLogInButtonView()
                .environment(\.window, window)
                .environment(\.managedObjectContext, viewContext)
            
            TempView(txt: userProfile.first!)
                .contentShape(Rectangle())
                .onTapGesture(perform: {
                    UserProfile.clearAllForDebug(in: viewContext)
                    print("Tapped") // TODO: FIx here
                })
            
            if showNaverLogin {
                NaverLoginView()
                    .frame(width: 0, height: 0)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct TempView: View {
    @ObservedObject var txt: UserProfile
    var body: some View {
        Text(txt.name)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
