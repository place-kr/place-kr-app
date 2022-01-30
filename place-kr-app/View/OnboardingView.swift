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
    @State var buttonClicked = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("어떤 장소를 찾고 계신가요?")
                            .font(.system(size: 24, weight: .bold))
                        Text("가고싶은 플레이스를 저희에게 알려주세요")
                            .font(.system(size: 14))
                    }
                    Spacer()
                }
                .padding(.horizontal, 13)
                .padding(.bottom, 24)
                
                VStack {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack {
                            ForEach(0..<3, id: \.self) { idx in
                                if idx == 1 {
                                    Spacer()
                                }
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray.opacity(0.5))
                                    .frame(width: 100, height: 100)
                                if idx == 1 {
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 47)
                
                NavigationLink(destination: MapView()) {
                    Text("시작하기")
                        .foregroundColor(.white)
                        .expandToMax(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.black))
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
