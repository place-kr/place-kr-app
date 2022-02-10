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
    
    var body: some View {
        TextField("현위치: {자동 입력}", text: $text)
            .modifier(TextFieldSearchButton(viewModel: viewModel, text: $text))
            .multilineTextAlignment(.leading)
            .frame(width: 280, height: 50)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(7)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
            .padding(.vertical)
    }
    
    init(viewModel: SearchFieldViewModel) {
        self.viewModel = viewModel
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
                        viewModel.fetchPlaces(text)
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
