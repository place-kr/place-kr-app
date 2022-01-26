//
//  OnboardingView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/25.
//

// https://github.com/Q-Mobile/QGrid
// https://github.com/paololeonardi/WaterfallGrid
// Hybrid VHstack

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<10, id: \.self) { _ in
                    HStack {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 21)
                                .fill(.gray.opacity(0.5))
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
