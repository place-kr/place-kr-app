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
    @Published var selectionCount = 0   // 퍼블리시를 위해 필요함. 야매임..
    
    private var imageDict = [UUID: ImageWrapper]()
    private var subscription = Set<AnyCancellable>()
    
    func submitSelectedImage() -> [ImageWrapper]{
        // TODO: 어딘가에 제출하기
        // 원래는 void 리턴
        let toBeSubmitted = images.filter { wrapper in
            if wrapper.isSelected {
                return true
            } else {
                return false
            }
        }
        self.selectionCount = 0
        
        return toBeSubmitted
    }
    
    func toggleOneSelection(_ id: UUID) {
        let isSelected = imageDict[id]!.isSelected
        if isSelected {
            imageDict[id]?.isSelected = false
            selectionCount -= 1
        } else {
            imageDict[id]?.isSelected = true
            selectionCount += 1
        }
    }
    
    // TODO: Caching
    init() {
        let imageUrls = Array(repeating: URL(string: "https://interactive-examples.mdn.mozilla.net/media/cc0-images/grapefruit-slice-332-332.jpg")!, count: 12)
    
        // URL로부터 퍼블리시
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
                    let imageWrapper = ImageWrapper(image: image)
                    
                    self.imageDict[imageWrapper.id] = imageWrapper
                    self.images.append(imageWrapper)
                })
                .store(in: &subscription)
        }
    }
}

extension OnboardingViewModel {
    class ImageWrapper: Hashable, Identifiable {
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
    @State var isSubmitted = false
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            VStack {
                header
                    .padding(.horizontal, 13)
                    .padding(.bottom, 24)
                
                imageGrid
                    .padding(.bottom, 47)
                
                Button(action: {
                    show = false
                    // TODO: 어딘가에 제출하기
                    let selected = viewModel.submitSelectedImage()
                }) {
                    Text("시작하기")
                        .foregroundColor(.white)
                }
                .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 52))
                .disabled(viewModel.selectionCount == 0 || isSubmitted)
                .transition(.opacity)
                .animation(.easeInOut)
            }
            .zIndex(0.5)
        }
        .padding(.horizontal, 16)
    }
}

extension OnboardingView {
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 7) {
                Text("어떤 장소를 찾고 계신가요?")
                    .font(.system(size: 24, weight: .bold))
                Text("가고싶은 플레이스를 저희에게 알려주세요")
                    .font(.system(size: 14))
            }
            Spacer()
        }
    }
    
    var imageGrid: some View {
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
                            let imageWrapper = viewModel.images[index]
                            checkable(imageWrapper, action: viewModel.toggleOneSelection)
                        }
                    }
                }
            }
        }
    }
}

@ViewBuilder
private func checkable(_ wrapper: OnboardingViewModel.ImageWrapper,
                       action toggle: @escaping (UUID) -> Void) -> some View {
    let image = Image(uiImage: wrapper.image)
    
    ZStack(alignment: .bottomTrailing) {
        image
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 105, height: 105)
            .cornerRadius(10)
            .onTapGesture {
                toggle(wrapper.id)
            }
        
        // Checkmark
        ZStack {
            Image(systemName: "checkmark.circle")
                .resizable()
                .foregroundColor(.white)
                .background(Circle().fill(.black))
                .frame(width: 19, height: 19)
                .zIndex(0.9)
            Circle()
                .fill(.white)
                .frame(width: 20, height: 20)
        }
        .padding(7)
        .opacity(wrapper.isSelected ? 1 : 0)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(show: .constant(true))
    }
}
