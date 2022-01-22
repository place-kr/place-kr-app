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
    
    var body: some View {
            LogInView()
                .environment(\.window, window)
                .environment(\.managedObjectContext, viewContext)
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
