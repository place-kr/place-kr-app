//
//  OpenSourcesLicences.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/25.
//

import SwiftUI

struct OpenSourcesLicences: View {
    
    let sources = [
        OpenSource(title: "BottomSheet", url: "https://github.com/lucaszischka/BottomSheet", description: "Copyright (c) 2021-2022 Lucas Zischka", license: "MIT License"),
        OpenSource(title: "SDWebImageSwiftUI", url: "https://github.com/SDWebImage/SDWebImageSwiftU", description: "Copyright (c) 2019 lizhuoli1126@126.com <lizhuoli1126@126.com>", license: "MIT License"),
        OpenSource(title: "SwiftUIPager", url: "https://github.com/fermoya/SwiftUIPager", description: "Copyright (c) 2019 fermoya", license: "MIT License")
    ]
    
    var body: some View {
        List {
            ForEach(sources.indices, id: \.self) { index in
                Block(source: sources[index])
            }
            
            VStack(alignment: .leading) {
                Text("MIT Licens")
                    .font(.basic.bold12)
                    .padding(.bottom, 7)

                Text("""
                     Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
                     
                     The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                     
                     THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                     """)
                .font(.basic.normal10)
            }
        }
        .listStyle(.plain)
        .navigationBarTitle("오픈소스 라이선스", displayMode: .inline)
    }
    
    struct OpenSource {
        let title: String
        let url: String
        let description: String
        let license: String
    }
    
    struct Block: View {
        let source: OpenSource
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(source.title)
                    .underline()
                    .font(.basic.bold12)
                    .onTapGesture {
                        let url = URL(string: source.url)
                        guard let url = url, UIApplication.shared.canOpenURL(url) else { return }
                        UIApplication.shared.open(url)
                    }
                    .padding(.bottom, 7)
                
                Text(source.description)
                    .font(.basic.normal10)
                Text(source.license)
                    .font(.basic.normal10)
            }
        }
    }
}

struct OpenSourcesLicences_Previews: PreviewProvider {
    static var previews: some View {
        OpenSourcesLicences()
    }
}
