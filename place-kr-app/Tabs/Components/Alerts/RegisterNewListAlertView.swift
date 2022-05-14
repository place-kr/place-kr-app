//
//  NewListAlertView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/03/29.
//

import SwiftUI
import Combine

struct RegisterNewListAlertView: View {
    @EnvironmentObject var viewModel: ListManager
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State var name = ""
    @State var emoji = String()
    @State var showEmojiKeyboard: Bool? = false
    
    @State var selectedColor: ListColor?
    @State var clicked = false
    
    @State var showWarning = false
    
    let colors: [ListColor] = ListColor.allCases
    let submitAction: () -> Void
    let requestType: RequestType
    let completion: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                
                Button(action: submitAction) {
                    Image(systemName: "xmark")
                }
                .foregroundColor(.black)
                .font(.basic.normal20)
            }
            .padding(.top, 20)
            
            // 헤더
            Text(requestType == .post ? "리스트 만들기" : "리스트 수정하기")
                .font(.basic.bold21)
                .padding(.bottom, 4)
            
            Text(requestType == .post ? "리스트명을 입력하세요" : "수정하고 싶은 정보를 입력하세요")
                .font(.basic.normal14)
                .padding(.bottom, showWarning ? 0 : 15)
            
            // 리스트 명 입력 텍스트필드
            EmojiSelector(text: $emoji, isResponder: $showEmojiKeyboard, keyboard: .default)
                .opacity(0.01)
                .frame(width: 0, height: 0)
                .onReceive(Just(emoji)) { value in
                    // 이모지 리턴
                    guard let emoji = value.last else { return }

                    if !emoji.isEmoji {
                        self.showWarning = true
                    } else {
                        self.showWarning = false
                    }
                    
                    self.emoji = String(emoji).onlyEmoji()
                    endTextEditing()
                }
            
            if showWarning {
                Text("아이콘은 이모지타입만 설정할 수 있습니다!")
                    .font(.basic.normal10)
                    .foregroundColor(.red)
            }
            
            ThemedTextField($name, "리스트명을 입력해주세요",
                            bgColor: .gray.opacity(0.3),
                            isStroked: false,
                            position: .trailing,
                            buttonImage: Image("emojiSelector") ,
                            buttonColor: .gray.opacity(0.5),
                            action: {
                DispatchQueue.main.async {
                    endTextEditing()
                    showEmojiKeyboard = true
                }
            })
            .padding(.bottom, 14)
            
            // 컬러 선택
            Text("리스트 컬러를 선택하세요")
                .padding(.bottom, 14)
                .font(.basic.normal14)
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    ForEach(0..<5, id: \.self) { index in
                        let colorName = colors[index]
                        let color = colorName.color
                        ZStack {
                            Circle().fill(color)
                            Text(emoji)
                            if selectedColor == colorName {
                                Circle().stroke(lineWidth: 1.5)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            self.selectedColor = colorName
                        }
                        if index != 4 {
                            Spacer()
                        }
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    ForEach(5..<10, id: \.self) { index in
                        let colorName = colors[index]
                        let color = colorName.color
                        ZStack {
                            Circle().fill(color)
                            Text(emoji)
                            if selectedColor == colorName {
                                Circle().stroke(lineWidth: 1.5)
                            }                        }
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            self.selectedColor = colorName
                        }
                        if index != 9 {
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    clicked = true
                    
                    switch requestType {
                    case .post:
                        let postBody = PlaceListPostBody(name: self.name, emoji: emoji, color: selectedColor?.HEX, places: [String]())
                        self.viewModel.addPlaceList(body: postBody) { result in
                            completion(result)
                        }
                    case .patch(let id):
                        self.viewModel.editListComponent(id: id, name: name, hex: selectedColor?.HEX) { result in
                            completion(result)
                        }
                    }
                }) {
                    Text("입력완료")
                }
                .disabled(name.isEmpty || selectedColor == nil || clicked)
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, cornerRadius: 20,  isStroked: false, width: 147, height: 40))
                .padding(.top, 25)
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .alertStyle()
    }
}

extension RegisterNewListAlertView {
    enum RequestType: Equatable {
        case post
        case patch(id: String)
    }
}

struct RegisterNewListView_Preview: PreviewProvider {
    static var previews: some View {
        RegisterNewListAlertView(submitAction: {}, requestType: .post, completion: {_ in })
    }
}
