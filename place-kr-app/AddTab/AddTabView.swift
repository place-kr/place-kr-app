//
//  AddTabView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/22.
//

import SwiftUI

struct AddTabView: View {
    var body: some View {
        SearchFieldView(viewModel: SearchFieldViewModel(),
                        color: Color(red: 243/255, green: 243/255, blue: 243/255),
                        placeholder: "검색 장소를 입력하세요"
        )
    }
}

struct AddTabView_Previews: PreviewProvider {
    static var previews: some View {
        AddTabView()
    }
}
