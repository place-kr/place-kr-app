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
    private let action: () -> Void
    private let backgroundColor: Color
    private let height: CGFloat
    private let isStroked: Bool
    private let placeholder: String
    
    var body: some View {
        TextField("", text: $inputText,
                  onEditingChanged: { self.isFocused = $0 },
                  onCommit: {
            if !inputText.isEmpty {
                print(inputText)
                didPressReturn()
            }
        })
        .placeholder(placeholder, when: inputText.isEmpty)
        .modifier(TextFieldSearchButton(text: $inputText, showButton: showButton, action: action))
        .multilineTextAlignment(.leading)
        .frame(minWidth: 200, maxWidth: .infinity, maxHeight: height)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 7).stroke(.black.opacity(isStroked ? 1 : 0)))
        .background(backgroundColor)
        .cornerRadius(7)
    }
    
    func didPressReturn() {
        self.action()
    }
    
    init(_ inputText: Binding<String>,
         _ placeholder: String = "현위치",
         isFocused: Binding<Bool>? = nil,
         bgColor: Color = .white,
         height: CGFloat = 50,
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
        self.height = height
    }
}

extension SearchBarView {
    private struct TextFieldButton: ViewModifier {
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
