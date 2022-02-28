//
//  MyPlaceDetailView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

struct PlaceListDetailView: View {
    @EnvironmentObject var viewModel: MyPlaceRowViewModel
    @State var isEditable = false
    
    var body: some View {
        VStack(alignment: .leading) {
            SimplePlaceCardView(viewModel.listName,
                                subscripts: "\(viewModel.places.count) places",
                                image: UIImage())
                .frame(height: 100)
                .padding(.horizontal, 17)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                        .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                )
            
            if !isEditable {
                Text("총 \(viewModel.places.count)개의 플레이스")
                    .font(.basic.subtitle)
            } else {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "checkbox")
                        Text("전체선택")
                    }
                }
            }
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.places, id: \.id) { place in
                        PlaceCardView(bgColor: .white, placeInfo: place)
                            .padding(.vertical)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white)
                                    .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                            )
                    }
                }
            }
        }
        .navigationBarItems(trailing: Button(action: { isEditable.toggle() }, label: {
            Text("Edit")
                .foregroundColor(.black)
        }))
        .navigationBarTitle("\(viewModel.listName)", displayMode: .inline) // TODO: 원본과 다름
        .padding(.horizontal, 15)
    }
}

struct PlaceListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceListDetailView()
    }
}
