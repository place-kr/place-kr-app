//
//  RequestPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/25.
//

import SwiftUI
import Combine

class RegisterPlaceviewModel: ObservableObject {
    @Published var progress: Progress = .ready
    
    private var subscriptions = Set<AnyCancellable>()
    
    func register(name: String, address: String, completion: @escaping (Bool)->()) {
        self.progress = .inProcess
        
        let registerRequest = RegisterRequest(name: name, address: address)
        
        RegisterManager.registerPlace(registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    self.progress = .failedWithError(error: error)
                    completion(false)
                case .finished:
                    self.progress = .finished
                    completion(true)
                }
                
                self.subscriptions.removeAll()
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
    }
}

struct RegisterPlaceView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel = RegisterPlaceviewModel()
    
    @State var showAddressSearch = false
    
    @State var placeName = ""
    @State var address = ""
    @State var restAddress = ""
    @State var descriptionText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: "플레이스 등록", leading: Image(systemName: "chevron.left"), leadingAction: {
                presentation.wrappedValue.dismiss()
            })
            .padding(.vertical)
            
            CustomDivider()
            
            headerTexts
                .padding(.vertical, 30)
            
            searchPlaceName
                .padding(.bottom, 20)
            
            searchAddr
                .padding(.bottom, 20)
            
            description
            
            Spacer()
            
            registerButton
                .padding(.bottom, 15)
        }
        .padding(.horizontal, 15)
        .overlay(
            Group{ if viewModel.progress == .inProcess { ProgressView(style: .medium) }}
        )
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

extension RegisterPlaceView {
    var headerTexts: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("플레이스를 요청해보세요")
                .font(.basic.bold17)
            Text("플레이스를 등록해주시면 ---님의 이름으로 플레이스가\n추가되며, 등록 내용을 실시간으로 알려드릴게요!")
                .font(.basic.light14)
                
            
            // Filler
            HStack {
                Spacer()
            }
        }
    }
    
    var searchPlaceName: some View {
        VStack(alignment: .leading, spacing:  6) {
            Text("플레이스명")
                .font(.basic.light14)
                .padding(.bottom, 4)

            SearchBarView($placeName, "플레이스 이름을 입력해주세요", bgColor: .white, height: 40, isStroked: true)
        }
    }
    
    var searchAddr: some View {
        VStack(alignment: .leading, spacing:  10) {
            Text("주소")
                .font(.basic.light14)
                .padding(.bottom, 4)
            
            SearchBarView($address, "주소찾기를 통해 주소를 입력하세요", bgColor: .white, height: 40, isStroked: true)
                .disabled(true)
            SearchBarView($restAddress, "나머지 주소를 입력해주세요", bgColor: .white, height: 40, isStroked: true)
            
            
            Button(action: { showAddressSearch = true }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("플레이스 검색하기")
                        .font(.system(size: 14))
                }
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 40))
        }
        .sheet(isPresented: $showAddressSearch) {
            addressSearch
        }
    }
    
    var addressSearch: some View {
        SearchKakaoPlaceView { result in
            self.address = result
        }
    }
    
    var description: some View {
        VStack(alignment: .leading) {
            Text("설명 (옵션)")
                .font(.basic.light14)
                .padding(.bottom, 4)

            SearchBarView($descriptionText, "플레이스에 대해 설명해주세요", bgColor: .white, height: 40, isStroked: true)
        }
    }
    
    var registerButton: some View {
        Button(action: {
            viewModel.register(name: self.placeName, address: self.address) { result in
                if result == true {
                    presentation.wrappedValue.dismiss()
                } else {
                    print("Error") // TODO: 고치기
                }
            }
        }) {
            Text("플레이스 등록 요청하기")
                .font(.system(size: 14))
        }
        .disabled(placeName.isEmpty || address.isEmpty || restAddress.isEmpty)
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isStroked: false, isSpanned: true, height: 52))
    }
}

struct RegisterPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPlaceView()
    }
}
