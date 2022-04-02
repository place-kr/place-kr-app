//
//  MyPlaceRowView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//

import SwiftUI
import BottomSheet

struct MyPlaceRowView: View {
    @ObservedObject var viewModel: MyPlaceRowViewModel
    let action: () -> ()

    var body: some View {
        SimplePlaceCardView(viewModel.listName,
                            subscripts: "\(viewModel.places.count) places",
                            image: UIImage(),
                            action: action)
        .padding(.horizontal, 12)
        
    }
}
