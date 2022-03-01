//
//  OnboardingView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/25.
//

// https://github.com/Q-Mobile/QGrid
// https://github.com/paololeonardi/WaterfallGrid
// Hybrid VHstack

import SwiftUI

import Combine
class OnboardingViewModel: ObservableObject {
    @Published var images = [ImageWrapper]()
    private var subscription = Set<AnyCancellable>()
    
    // TODO: Caching
    init() {
        let imageUrls = Array(repeating: URL(string: "https://interactive-examples.mdn.mozilla.net/media/cc0-images/grapefruit-slice-332-332.jpg")!, count: 12)
        
        for url in imageUrls {
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { result in
                    switch result {
                    case let .failure(error):
                        print("Load failed: \(error)")
                    case .finished:
                        print("Successed to load image")
                    }
                }, receiveValue: { image in
                    let image = UIImage(data: image.data)!
                    self.images.append(ImageWrapper(image: image))
                })
                .store(in: &subscription)
        }
    }
}

extension OnboardingViewModel {
    struct ImageWrapper: Hashable, Identifiable {
        let id = UUID()
        var isSelected = false
        var image: UIImage
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: ImageWrapper, rhs: ImageWrapper) -> Bool {
            return lhs.id == rhs.id && lhs.id == rhs.id
        }
        
        init(image: UIImage) {
            self.image = image
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var viewModel = OnboardingViewModel()
    @Binding var isClicked: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text("어떤 장소를 찾고 계신가요?")
                        .font(.system(size: 24, weight: .bold))
                    Text("가고싶은 플레이스를 저희에게 알려주세요")
                        .font(.system(size: 14))
                }
                Spacer()
            }
            .padding(.horizontal, 13)
            .padding(.bottom, 24)
            
            VStack(spacing: 15) {
                ForEach(0..<4, id: \.self) { col in
                    HStack(spacing: 15) {
                        ForEach(0..<3, id: \.self) { row in
                            let index = col * 3 + row
                            if index >= viewModel.images.count {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 105, height: 105)
                            } else {
                                let image = Image(uiImage: viewModel.images[index].image)
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 105, height: 105)
                                    .cornerRadius(5)
                            }
                        }
                        
                    }
                }
            }
            .padding(.bottom, 47)
            
            Button(action: { isClicked = false }) {
                Text("시작하기")
                    .foregroundColor(.white)
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .gray, textColor: .white, isStroked: false, height: 52))
        }
        .padding(.horizontal, 16)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isClicked: .constant(true))
    }
}
