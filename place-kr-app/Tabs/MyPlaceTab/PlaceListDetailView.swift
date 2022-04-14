//
//  MyPlaceDetailView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

struct PlaceListDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PlaceListDetailViewModel
    @State var isEditable = false
    
    init(viewModel: PlaceListDetailViewModel) {
        self.viewModel = viewModel
        viewModel.fetchMultipleInfos()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            PageHeader(title: "나의 플레이스",
                       leading: Image(systemName: "chevron.left"),
                       leadingAction: { presentationMode.wrappedValue.dismiss() },
                       trailing: Text(isEditable ? "수정완료" : "Edit").foregroundColor(isEditable ? .red : .black),
                       trailingAction: {
                isEditable.toggle()
                viewModel.resetSelection()
            })
            .padding(.vertical, 17)
            .padding(.horizontal, 15)
            
            CustomDivider()
                .padding(.bottom, 17)
            
            if isEditable {
                editableView
            } else {
                // 헤더에 올라가는 리스트 카드 뷰
                Group {
                    SimplePlaceCardView(viewModel.listName, hex: viewModel.listColor,
                                        subscripts: "\(viewModel.places.count) places",
                                        image: UIImage())
                        .frame(height: 100)
                        .padding(.horizontal, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                                .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                        )
                    
                    Text("총 \(viewModel.places.count)개의 플레이스")
                        .font(.basic.light14)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 15)
                
                ZStack {
                    Color.backgroundGray
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        // 플레이스 리스트
                        VStack(spacing: 7) {
                            if viewModel.places.isEmpty {
                                Text("아직 플레이스가 없어요\n 지도에서 플레이스를 추가해보세요!")
                                    .multilineTextAlignment(.center)
                                    .font(.basic.normal15)
                                    .padding(.vertical, 40)
                                    .foregroundColor(.gray)
                                
                                AdditionButton
                                Spacer()
                            } else {
                                ForEach(viewModel.places, id: \.id) { wrapper in
                                    let place = wrapper.placeInfo
                                    LightCardView(place: place, isFavorite: wrapper.isSelected)
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.white)
                                                .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                                        )
                                }

                                AdditionButton
                                    .padding(.top, 20)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 15)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

extension PlaceListDetailView {
    var AdditionButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Spacer()
                Text("+ 플레이스 추가하기")
                    .font(.basic.normal15)
                Spacer()
            }
        })
        .frame(height: 52)
        .foregroundColor(.gray)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(.gray))
    }
    
    var editableView: some View {
        ZStack {
            if viewModel.selectionCount != 0 {
                VStack {
                    Spacer()
                    Button(action: { viewModel.deleteSelected() }) {
                        Text("삭제하기")
                    }
                    .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 50))
                    .padding(.bottom, 15)
                    .padding(.horizontal, 15)
                }
                .zIndex(1)
                .transition(.move(edge: .bottom))
                .animation(.spring())
            }
            
            VStack {
                VStack {
                    SimplePlaceCardView(viewModel.listName, hex: viewModel.listColor,
                                        subscripts: "\(viewModel.places.count) places",
                                        image: UIImage())
                        .frame(height: 100)
                        .padding(.horizontal, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                                .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                        )
                    
                    HStack {
                        Button(action: { viewModel.toggleAllSelection() }) {
                            Image(systemName: !viewModel.isAllSelected ? "square" : "checkmark.square")
                            Text("전체선택")
                        }
                        .font(.basic.light14)
                        .foregroundColor(.black)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 15)
                
                ZStack {
                    Color.backgroundGray
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        // 플레이스 리스트
                        VStack(spacing: 7) {
                            ForEach(viewModel.places, id: \.id) { wrapper in
                                let place = wrapper.placeInfo
                                LightCardView(place: place, isFavorite: wrapper.isSelected)
                                    .padding(10)
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.black.opacity(wrapper.isSelected ? 1 : 0))
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.white)
                                            .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.toggleOneSelection(wrapper.id)
                                    }
                            }
                        }
                        .animation(.spring())
                        .padding(.top, 12)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }
}

//struct PlaceListDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaceListDetailView()
//    }
//}
