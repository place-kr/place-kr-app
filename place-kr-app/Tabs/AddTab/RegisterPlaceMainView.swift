//
//  RegisterPlaceMainView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/04/14.
//

import SwiftUI
import Combine

class RegisterPlaceMainViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var progress: Progress = .ready
    @Published var requests = [RegisterRequest]()
    
    func register(name: String, address: String, coord: (String, String), completion: @escaping (Bool)->()) {
        self.progress = .inProcess
        
        let registerRequest = RegisterRequest(name: name, x: coord.0, y: coord.1, address: address)
        
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

struct RegisterPlaceMainView: View {
    @ObservedObject var viewModel = RegisterPlaceMainViewModel()
    @State var navigateToRegister = false
    
    var body: some View {
        VStack {
            // 네비게이트 대상
            Navigators
            
            PageHeader(title: "플레이스 등록", trailing: Text("등록하기"), trailingAction: {})
                .padding(.vertical, 17)
            
            CustomDivider()
            
            EmptyCaseView
            
            Button(action: { navigateToRegister = true }) {
                Text("플레이스 등록하기")
            }
            .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isSpanned: true, height: 52))
            .padding(.bottom, 20)
        }
        .navigationBarTitle("")
        .padding(.horizontal, 15)
    }
}

extension RegisterPlaceMainView {
    var Navigators: some View {
        NavigationLink(destination: RegisterPlaceView().environmentObject(viewModel) , isActive: $navigateToRegister) {
            EmptyView()
        }
    }
    
    var EmptyCaseView: some View {
        VStack {
            Spacer()
            
            Image("addEmpty")
                .resizable()
                .frame(width: 65, height: 80)
                .padding(.bottom, 55)
            
            Text("직접 플레이스를 등록해보세요")
                .font(.basic.bold17)
                .padding(.bottom, 9)
            
            Text("여러분의 플레이스 등록 참여로\n 더욱 풍성한 플레이스를 만들어주세요")
                .multilineTextAlignment(.center)
                .font(.basic.normal14)

            Spacer()
        }
    }
}

struct RegisterPlaceMainView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPlaceMainView()
    }
}
