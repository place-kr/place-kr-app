//
//  CommentAlertView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/10.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textView.textColor = .black
        textView.backgroundColor = .gray.withAlphaComponent(0.3)
        
        textView.layer.cornerRadius = 7
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        textView.textContainer.maximumNumberOfLines = 3
        textView.delegate = context.coordinator

        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = self.text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
        }
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
    }
}

struct CommentAlertView: View {
    @Binding var text: String
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
            
            TextView(text: $text)
                .frame(height: 80)
            
            HStack {
                Spacer()
                Button(action: { action() }) {
                    Text("입력완료")
                }
                .disabled(clicked || text.isEmpty)
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, width: 147, height: 40))
                .padding(.top, 25)
                .padding(.bottom, 20)
                
                Spacer()
            }
            
        }
        .alertStyle()
    }
}
