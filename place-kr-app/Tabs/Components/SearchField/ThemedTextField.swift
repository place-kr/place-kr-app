//
//  ThemedTextField.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/02.
//

import SwiftUI

struct ThemedTextField: View {
    @Binding var inputText: String
    @Binding var isFocused: Bool
    
    private let placeholder: String

    private let backgroundColor: Color
    private let isStroked: Bool
    
    private let buttonPosition: ButtonPosition
    private let buttonName: String
    private let buttonColor: Color
    
    private let action: (() -> Void)

    var body: some View {
        TextField(placeholder, text: $inputText, onEditingChanged: { isFocused in
            self.isFocused = isFocused
        })
            .modifier(
                TextFieldButton(text: $inputText, buttonPosition: buttonPosition,
                                buttonName: buttonName, buttonColor: buttonColor, action: action)
            )
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
         buttonName: String,
         buttonColor: Color,
         action: @escaping (() -> Void))
    {
        self._inputText = inputText
        self.placeholder = placeholder
        self.isStroked = isStroked
        self.backgroundColor = bgColor
        self.buttonPosition = position
        self.buttonName = buttonName
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
        self.buttonName = ""
        self.buttonColor = .clear
    }
}

extension ThemedTextField {
    enum ButtonPosition {
        case leading
        case trailing
        case none
    }
    
    private struct TextFieldButton: ViewModifier {
        @Binding var text: String
        let buttonPosition: ButtonPosition
        let buttonName: String
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
                    if !text.isEmpty {
                        action()
                    }
                },
                label: {
                    Image(systemName: buttonName)
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