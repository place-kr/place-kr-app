//
//  EmojiSelector.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/24.
//

import SwiftUI

class UIEmojiTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setEmoji() {
        _ = self.textInputMode
    }
    
    override var textInputContextIdentifier: String? {
           return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default // do not remove this
                return mode
            }
        }
        return nil
    }
}


struct EmojiSelector: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        @Binding var isResponder : Bool?
        
        init(text: Binding<String>, isResponder : Binding<Bool?>) {
            _text = text
            _isResponder = isResponder
        }
                
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isResponder = true
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isResponder = false
            }
        }
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            guard let textFieldText = textField.text else {
                return false
            }

            textField.text = textFieldText.onlyEmoji()

            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            guard let textFieldText = textField.text,
                  let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
            }
            
            textField.text = textFieldText.onlyEmoji()
            
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            return count <= 2
        }
    }
    
    @Binding var text: String
    @Binding var isResponder : Bool?
    
    var keyboard : UIKeyboardType
    
    func makeUIView(context: UIViewRepresentableContext<EmojiSelector>) -> UITextField {
        let textField = UIEmojiTextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = keyboard
        textField.delegate = context.coordinator
        return textField
    }
    
    func makeCoordinator() -> EmojiSelector.Coordinator {
        return Coordinator(text: $text, isResponder: $isResponder)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<EmojiSelector>) {
        uiView.text = text
        if isResponder ?? false {
            uiView.becomeFirstResponder()
        }
    }
    
}
