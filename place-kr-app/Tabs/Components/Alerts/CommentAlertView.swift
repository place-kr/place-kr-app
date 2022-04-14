//
//  CommentAlertView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/10.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    
    typealias UIViewType = UITextView
    var configuration = { (view: UIViewType) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let textView = UITextView()

        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textView.textColor = .black
        textView.backgroundColor = .gray.withAlphaComponent(0.3)
        
        textView.layer.cornerRadius = 7

        textView.textContainer.maximumNumberOfLines = 3

        
        return textView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}

struct CommentAlertView: View {
    @State var text: String = ""
    @State var clicked = false
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("플레이스 한줄 평")
                .font(.basic.bold21)
                .padding(.top, 40)
            Text("플레이스를 방문하셨나요? 평가를 남겨보세요")
                .font(.basic.light14)
                .padding(.bottom, 15)
            
            TextView() {
                $0.text = text
            }
            .frame(height: 80)
            
            HStack {
                Spacer()
                Button(action: { action() }) {
                    Text("입력완료")
                }
                .disabled(clicked)
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, width: 147, height: 40))
                .padding(.top, 25)
                .padding(.bottom, 20)
                
                Spacer()
            }
            
        }
        .alertStyle()
    }
}
