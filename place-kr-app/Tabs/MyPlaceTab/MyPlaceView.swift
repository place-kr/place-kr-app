//
//  MyPlaceView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/17.
//

import SwiftUI
import BottomSheet

class MyPlaceViewModel: ObservableObject {
    @Published var progress: Progress = .ready
}

struct MyPlaceView: View {
    @EnvironmentObject var listManager: ListManager
    @ObservedObject var viewModel = MyPlaceViewModel()
    
    @State var bottomSheetPosition: PlaceListSheetPosition = .hidden
    @State var selectedList: PlaceList?
    
    @State var showShareSheet = false
    @State var showEditSheet = false
    @State var showNewListAlert = false
    @State var showDeleteAlert = false
    @State var showWarning = false
    
    @State var text = ""
    @State var position: CGFloat = 0
    
    @Binding var selection: TabsView.Tab

    var body: some View {
        ZStack {
            if viewModel.progress == .inProcess {
                CustomProgressView
                    .zIndex(1)
            }
            
            VStack {
                VStack {
                    // 페이지 헤더 부분
                    PageHeader(title: "나의 플레이스", trailing: Text("추가하기"), trailingAction: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            self.showNewListAlert = true
                        }
                    })
                    .padding(.bottom, 18)
                    .padding(.horizontal, 15)

                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .frame(maxHeight: 0.5)
                        .padding(.bottom, 18)
                }
                .padding(.top, 20)

                // MARK: - 플레이스 리스트
                VStack(spacing: 15) {
                    HStack {
                        Text("총 \(listManager.placeLists.count)개의 플레이스 리스트가 있습니다")
                            .font(.basic.normal12)
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    Button(action: { listManager.updateLists(page: 2) }) {
                        Text("추가하기(mock)")
                    }
                    
                    TrackableScrollView(position: self.$position) {
                        VStack(spacing: 10) {
                            // MARK: -리스트 카드 뷰
                            ForEach(listManager.placeLists, id: \.identifier) { list in
                                navigator(list: list, label:
                                            SimplePlaceCardView(list.name,
                                                                hex: list.color,
                                                                subscripts: "\(list.places.count) places",
                                                                image: UIImage(),
                                                                buttonLabel: Image(systemName: "ellipsis"),
                                                                action: {
                                                self.selectedList = list
                                                withAnimation(.spring()) {
                                                    bottomSheetPosition = .bottom
                                                }})
                                            .padding(.horizontal, 12)
                                )
                                .frame(height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.white)
                                        .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                                )
                                .foregroundColor(.black)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                     options: [
                        .animation(springAnimation), .background(AnyView(Color.white)), .cornerRadius(20), .absolutePositionValue,
                        .noBottomPosition, .swipeToDismiss, .tapToDismiss, .backgroundBlur(effect: .dark),
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: -5)
                     ]
                     ,
                     headerContent: {
            HStack {
                Text("플레이스 리스트 관리")
                    .font(.system(size: 21, weight: .bold))
                    .padding(.top, 20)
                    .padding(.bottom, 13.5)
                Spacer()
                Button(action: {
                    print("SSS")
                    withAnimation(.spring()) {
                        bottomSheetPosition = .hidden
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, 15)
        },
                     mainContent: {
            managePlaceList
                .padding(.horizontal, 28)
        })
        .showAlert(show: $showNewListAlert, alert: RegisterNewListAlertView(submitAction: {
            // MARK: - 새로운 리스트 등록
            // 닫기버튼 누른 후
            viewModel.progress = .finished
            withAnimation(.spring()) {
                showNewListAlert = false
            }
        }, requestType: .post, completion: { result in
            // 입력 완료 후 결과 기다릴 때
            DispatchQueue.main.async {
                switch result {
                case true:
                    bottomSheetPosition = .hidden
                    viewModel.progress = .finished
                    break
                case false:
                    viewModel.progress = .failed
                    self.showWarning = true
                    break
                }
                
                withAnimation(.spring()) {
                    showNewListAlert = false
                }
            }
        }).environmentObject(listManager)
        )
        .showAlert(show: $showEditSheet, alert: EditListNameAlertView(name: $text, action: {
            // MARK: - 리스트 이름만 편집 팝업
            guard let selectedList = self.selectedList else { return }
            viewModel.progress = .inProcess
            
            listManager.editListComponent(id: selectedList.identifier, name: self.text) { result in
                DispatchQueue.main.async {
                    switch result {
                    case true:
                        bottomSheetPosition = .hidden
                        self.text = ""
                        viewModel.progress = .finished
                        break
                    case false:
                        self.text = ""
                        viewModel.progress = .failed
                        self.showWarning = true
                        break
                    }
                    
                    withAnimation(.spring()) {
                        showEditSheet = false
                    }
                }
            }
        }))
        .alert(isPresented: $showWarning) {
            basicSystemAlert(title: "네트워크 오류 발생", content: "잠시 후 다시 시도해주세요")
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("리스트를 삭제하시겠어요?"), primaryButton: .cancel(), secondaryButton: .default(Text("Ok"), action: {
                guard let selectedList = self.selectedList else { return }
                viewModel.progress = .inProcess
                
                listManager.deletePlaceList(id: selectedList.identifier) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case true:
                            bottomSheetPosition = .hidden
                            viewModel.progress = .finished
                            return
                        case false:
                            viewModel.progress = .failed
                            return
                        }
                    }
                }
            }))
        }
        .navigationBarTitle("") //this must be empty
        .navigationBarHidden(true)
    }
}

extension MyPlaceView {
    @ViewBuilder
    func navigator<T: View>(list: PlaceList?, label: T) -> some View {
        switch list {
        case nil:
            label
        default:
            NavigationLink(
                destination: LazyView {
                    PlaceListDetailView(viewModel: PlaceListDetailViewModel(list: list!, listManager: listManager), selection: $selection)
                        .environmentObject(listManager)
                },
                label: { label })
        }
    }
    
    var managePlaceList: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                showShareSheet = true
                withAnimation(.spring()) {
                    bottomSheetPosition = .hidden
                }
            }) {
                HStack(spacing: 9) {
                    Image(systemName: "square")
                    Text("공유하기")
                    Spacer()
                }
            }
            
            Divider()
            
            Button(action: {
                withAnimation(.spring()) {
                    showEditSheet = true
                }
            }) {
                HStack(spacing: 9) {
                    Image(systemName: "pencil")
                    Text("리스트명 변경하기")
                    Spacer()
                }
            }
            
            Divider()

            navigator(list: self.selectedList, label:
                HStack(spacing: 9) {
                    Image(systemName: "mappin")
                    Text("플레이스 편집하기")
                Spacer()
                }
            )
            
            Divider()
            
            // 플레이스 삭제하기
            Button(action: {
                print(showDeleteAlert)
                self.showDeleteAlert = true
            }) {
                HStack(spacing: 9) {
                    Image(systemName: "trash")
                    Text("삭제하기")
                    Spacer()
                }
            }
        }
        .font(.system(size: 14))
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["Hello world"])
        }
    }
}

struct MyPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaceView(selection: .constant(.map))
    }
}
