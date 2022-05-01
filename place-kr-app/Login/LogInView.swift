//
//  LogInView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/22.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    struct ImageCell {
        let id = UUID()
        let image: Image
    }
    
    let imageNames: [String]

    let imageCells: [ImageCell]
    
    init() {
        self.imageNames = [
           "mainIcon1", "mainIcon2", "mainIcon3", "mainIcon4", "mainIcon5", "mainIcon6",
           "mainIcon1", "mainIcon2", "mainIcon3", "mainIcon4", "mainIcon5", "mainIcon6",
           "mainIcon1", "mainIcon2", "mainIcon3", "mainIcon4", "mainIcon5", "mainIcon6"
       ]
        
        self.imageCells = imageNames.map { name in
           ImageCell(image: Image(name))
       }
    }
}

// TODO: 자동로그인
struct LogInView: View {
    @EnvironmentObject var loginManager: LoginManager
    @Environment(\.window) var window: UIWindow?
    
    @State var moveX: CGFloat = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @ObservedObject var viewModel = LoginViewModel()

    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                /// 앱 로고 디폴트 이미지
                HStack {
                    Spacer()
                    ZStack(alignment: .bottomLeading) {
                        Image("mainLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 84)
                            .padding(.bottom, 40)
                            .zIndex(1)
                        
                        HStack(spacing: 0) {
                            ForEach(viewModel.imageCells, id: \.id) { cell in
                                cell.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width-100, height: 60)
                        .onReceive(timer, perform: { fire in
                            withAnimation {
                                moveX -= 50
                            }

                            if moveX <= -300 {
                                moveX = 0
                            }
                        })
//                        .contentShape(Rectangle())
//                        .clipped()
                        .offset(x: moveX + 20, y: 7)
                        .transition(.slide)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("PLAIST")
                        .font(.basic.logo)
                        .padding(.bottom, 14)
                    
                    Text("플레이스트에서 나만의 플레이스를\n 만들고, 즐겨보세요!")
                        .font(.system(size: 17))
                }
                
                Spacer()
                
                NaverLoginButtonView()
                    .environmentObject(loginManager)
                    .padding(.bottom, 10)

                AppleLogInView(viewModel: AppleLoginViewModel(window: window))
                    .frame(height: 54)
                    .environment(\.window, window)
                    .environmentObject(loginManager)
                    .padding(.bottom, 60)
                
                ZStack {
                    // TODO: 링크 연계
                    Text("소셜 로그인을 통해 로그인함으로써 개인정보처리방침¹과 이용약관²에 따라 계정을 연결하는 것에 동의합니다.")
                }
                .onTapGesture {
                    UIApplication.shared.open(URL(string: "https://www.naver.com")!)
                }
                .font(.system(size: 12))
                .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 27)
    }
    
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
