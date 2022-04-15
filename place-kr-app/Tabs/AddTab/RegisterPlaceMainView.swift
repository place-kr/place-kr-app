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
    
    func fetchRequests() {
        RegisterManager.fetchRequests()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    self.progress = .failedWithError(error: error)
                    print("[RegisterPlaceMainViewModel] error: \(error.localizedDescription)")
                case .finished:
                    self.progress = .finished
                    print("[RegisterPlaceMainViewModel] Fetched")
                }
                
                self.subscriptions.removeAll()
            }, receiveValue: { [weak self] values in
                guard let self = self else { return }
                
                self.requests = values.results
            })
            .store(in: &subscriptions)
    }
    
    init() {
        self.fetchRequests()
    }
}

struct RegisterPlaceMainView: View {
    @ObservedObject var viewModel = RegisterPlaceMainViewModel()
    @State var navigateToRegister = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 네비게이트 대상
            Navigators
            
            PageHeader(title: "플레이스 등록", trailing: Text("등록하기"), trailingAction: { navigateToRegister = true })
                .padding(.vertical, 17)
                .padding(.horizontal, 15)

            CustomDivider()
                .padding(.bottom, 8.5)
            
            HStack {
                Text("\(viewModel.requests.count)건의 등록요청이 있습니다")
                    .font(.basic.normal14)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                
                Spacer()
            }
            .padding(.horizontal, 15)
            
            // MARK: - 리퀘스트 리스트
            ZStack {
                Color.backgroundGray
                
                Group {
                    if viewModel.requests.isEmpty {
                        EmptyCaseView
                        
                        RegisterButton
                            .padding(.bottom, 20)
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(viewModel.requests) { request in
                                    RequestCardView(place: request)
                                        .padding(.horizontal, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                        )
                                        .frame(height: 70)
                                }
                                
                                RegisterButton
                                    .padding(.vertical, 20)
                            }
                            .padding(.top, 14)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            
            
        }
        .navigationBarTitle("")
    }
}

extension RegisterPlaceMainView {
    var Navigators: some View {
        NavigationLink(destination: RegisterPlaceView().environmentObject(viewModel) , isActive: $navigateToRegister) {
            EmptyView()
        }
    }
    
    var RegisterButton: some View {
        Button(action: { navigateToRegister = true }) {
            Text("플레이스 등록하기")
        }
        .buttonStyle(RoundedButtonStyle(bgColor: .black, textColor: .white, isSpanned: true, height: 52))
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
