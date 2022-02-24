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
    
    private let action: (() -> Void)
    private let backgroundColor: Color
    private let placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $inputText, onEditingChanged: { isFocused in
            self.isFocused = isFocused
        })
            .modifier(TextFieldSearchButton(text: $inputText, action: action))
            .multilineTextAlignment(.leading)
            .frame(minWidth: 200, maxWidth: .infinity, maxHeight: 50)
            .padding(.horizontal)
            .background(backgroundColor)
            .cornerRadius(7)
    }
    
    init(_ inputText: Binding<String>, isFocused: Binding<Bool>? = nil, _ bgColor: Color = .white,
         _ placeholder: String = "현위치", action: @escaping () -> Void) {
        self._inputText = inputText
        self._isFocused = isFocused ?? Binding.constant(false)
        self.backgroundColor = bgColor
        self.placeholder = placeholder
        self.action = action
    }
}

extension SearchBarView {
    /// Add button at search field
    private struct TextFieldSearchButton: ViewModifier {
        @Binding var text: String
        let action: () -> Void
        
        func body(content: Content) -> some View {
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
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFieldView(viewModel: SearchManager())
    }
}
