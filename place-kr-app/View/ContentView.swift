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
    @Environment(\.window) var window: UIWindow?
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @State var isLoginSuccessed = false
    
    var body: some View {
        if !isLoginSuccessed {
            LogInView(success: $isLoginSuccessed)
                .environment(\.window, window)
                .environment(\.managedObjectContext, viewContext)
        } else {
            Text("Login Successed!")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
