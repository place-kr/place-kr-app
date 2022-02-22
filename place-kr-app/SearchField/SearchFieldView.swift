//
//  SearchFieldView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import SwiftUI

struct SearchFieldView: View {
    @State var text = ""
    @ObservedObject var viewModel: SearchFieldViewModel
    
    private let backgroundColor: Color
    private let placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .modifier(TextFieldSearchButton(viewModel: viewModel, text: $text))
            .multilineTextAlignment(.leading)
            .frame(minWidth: 200, maxWidth: .infinity, maxHeight: 50)
            .padding(.horizontal)
            .background(backgroundColor)
            .cornerRadius(7)
    }
    
    init(viewModel: SearchFieldViewModel, color: Color = .white, placeholder: String = "현위치") {
        self.viewModel = viewModel
        self.backgroundColor = color
        self.placeholder = placeholder
    }
}

extension SearchFieldView {
    /// Add button at search field
    private struct TextFieldSearchButton: ViewModifier {
        @ObservedObject var viewModel: SearchFieldViewModel
        @Binding var text: String
        
        func body(content: Content) -> some View {
            HStack {
                Button(
                    action: {
                        if !text.isEmpty {
                            viewModel.fetchPlaces(text)
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

struct SearchFieldView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFieldView(viewModel: SearchFieldViewModel())
    }
}
