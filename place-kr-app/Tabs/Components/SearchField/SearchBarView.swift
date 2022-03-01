//
//  SearchFieldView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var inputText: String
    @Binding var isFocused: Bool
    
    private let showButton: Bool
    private let action: (() -> Void)
    private let backgroundColor: Color
    private let isStroked: Bool
    private let placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $inputText, onEditingChanged: { isFocused in
            self.isFocused = isFocused
        })
            .modifier(TextFieldSearchButton(text: $inputText, showButton: showButton ,action: action))
            .multilineTextAlignment(.leading)
            .frame(minWidth: 200, maxWidth: .infinity, maxHeight: 50)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 7).stroke(.black.opacity(isStroked ? 1 : 0)))
            .background(backgroundColor)
            .cornerRadius(7)
    }
    
    init(_ inputText: Binding<String>,
         _ placeholder: String = "현위치",
         isFocused: Binding<Bool>? = nil,
         bgColor: Color = .white,
         isStroked: Bool = false,
         action: (() -> Void)? = nil)
    {
        self._inputText = inputText

        if let isFocused = isFocused {
            self._isFocused = isFocused
        } else {
            self._isFocused = Binding.constant(false)
        }
        
        if let action = action {
            self.action = action
            self.showButton = true
        } else {
            self.action = {}
            self.showButton = false
        }
        
        self.isStroked = isStroked
        self.backgroundColor = bgColor
        self.placeholder = placeholder
    }
}

extension SearchBarView {
    /// Add button at search field
    private struct TextFieldSearchButton: ViewModifier {
        @Binding var text: String
        let showButton: Bool
        let action: () -> Void
        
        func body(content: Content) -> some View {
            if showButton {
                HStack {
                    Button(
                        action: {
                            if !text.isEmpty {
                                action()
                            }
                        },
                        label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                        }
                    )
                    content
                        .padding(.leading, 5)
                }
            } else {
                content
            }
        }
    }
        
    private struct WithoutButton: ViewModifier {
        func body(content: Content) -> some View {
            content
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFieldView(viewModel: SearchManager())
    }
}