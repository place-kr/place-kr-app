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
    @State var isLoginSuccessed = false
    
    var body: some View {
        if !isLoginSuccessed {
//            MapView()
            LogInView(success: $isLoginSuccessed)
                .environment(\.window, window)
        } else {
            OnboardingView()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
