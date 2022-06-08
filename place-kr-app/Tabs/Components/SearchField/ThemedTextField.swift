//
//  ThemedTextField.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

struct ThemedTextField<V: View>: View {
    @Binding var inputText: String
    @Binding var isFocused: Bool
    
    private let placeholder: String

    private let backgroundColor: Color
    private let isStroked: Bool
    
    private let buttonPosition: ButtonPosition
    private let buttonImage: V
    private let buttonColor: Color
    
    private let action: (() -> Void)

    var body: some View {
        TextField("", text: $inputText, onEditingChanged: { isFocused in
            self.isFocused = isFocused
        })
            .modifier(
                TextFieldButton(text: $inputText, buttonPosition: buttonPosition,
                                buttonImage: buttonImage, buttonColor: buttonColor, action: action)
            )
            .placeholder(placeholder, when: inputText.isEmpty)
            .multilineTextAlignment(.leading)
            .frame(minWidth: 200, maxWidth: .infinity, maxHeight: 50)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 7).stroke(.black.opacity(isStroked ? 1 : 0)))
            .background(backgroundColor)
            .cornerRadius(7)
    }
    
    init(_ inputText: Binding<String>,
         _ placeholder: String,
         bgColor: Color,
         isStroked: Bool,
         isFocused: Binding<Bool>? = nil,
         position: ButtonPosition,
         buttonImage: V,
         buttonColor: Color,
         action: @escaping (() -> Void))
    {
        self._inputText = inputText
        self.placeholder = placeholder
        self.isStroked = isStroked
        self.backgroundColor = bgColor
        self.buttonPosition = position
        self.buttonImage = buttonImage
        self.buttonColor = buttonColor

        if let isFocused = isFocused {
            self._isFocused = isFocused
        } else {
            self._isFocused = Binding.constant(false)
        }
        
        self.action = action
    }
    
    init(_ inputText: Binding<String>,
         _ placeholder: String,
         bgColor: Color,
         isStroked: Bool,
         isFocused: Binding<Bool>? = nil)
    {
        self._inputText = inputText
        self.placeholder = placeholder
        self.isStroked = isStroked
        self.backgroundColor = bgColor

        if let isFocused = isFocused {
            self._isFocused = isFocused
        } else {
            self._isFocused = Binding.constant(false)
        }
        
        self.action = {}
        self.buttonPosition = .none
        self.buttonImage = Image(systemName: "person") as! V
        self.buttonColor = .clear
    }
}

extension ThemedTextField {
    enum ButtonPosition {
        case leading
        case trailing
        case none
    }
    
    private struct TextFieldButton<V: View>: ViewModifier {
        @Binding var text: String
        let buttonPosition: ButtonPosition
        let buttonImage: V
        let buttonColor: Color
        let action: () -> Void
        
        func body(content: Content) -> some View {
            HStack {
                if buttonPosition == .leading {
                    button
                    
                    content
                        .padding(.leading, 5)
                }
                
                if buttonPosition == .trailing {
                    content
                        .padding(.trailing, 5)
                    
                    button
                }
            }
        }
        
        var button: some View {
            Button(
                action: {
                    action()
                },
                label: {
                    buttonImage
                        .foregroundColor(buttonColor)
                }
            )
        }

    }
}


//struct ThemedTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemedTextField(<#Binding<String>#>, <#String#>, bgColor: <#Color#>, isStroked: <#Bool#>)
//    }
//}
