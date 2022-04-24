//
//  MyPlaceDetailView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/26.
//

import SwiftUI

struct PlaceListDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listManager: ListManager
    @ObservedObject var viewModel: PlaceListDetailViewModel
    
    @State var isEditable = false
    @State var showEditPopup = false
    @State var showWarning = false
    
    @State var isBottom = false
    
    @Binding var selection: TabsView.Tab
    
    init(viewModel: PlaceListDetailViewModel, selection: Binding<TabsView.Tab>) {
        self.viewModel = viewModel
        self._selection = selection
        
        viewModel.fetchMultipleInfos()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            PageHeader(title: "나의 플레이스",
                       leading: Image(systemName: "chevron.left"),
                       leadingAction: { presentationMode.wrappedValue.dismiss() })
            .padding(.vertical, 17)
            .padding(.horizontal, 15)
            
            CustomDivider()
                .padding(.bottom, 17)
            
            // 헤더에 올라가는 리스트 카드 뷰
            Group {
                SimplePlaceCardView(viewModel.listName, hex: viewModel.listColor, emoji: viewModel.emoji,
                                    subscripts: "\(viewModel.places.count) places",
                                    image: UIImage(), buttonLabel: Text("Edit"), action:  {
                    withAnimation(.spring()) {
                        showEditPopup = true
                    }
                })
                .frame(height: 100)
                .padding(.horizontal, 17)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                        .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                )
                
                Text("총 \(viewModel.places.count)개의 플레이스")
                    .font(.basic.light14)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 15)
            
            ZStack {
                Color.backgroundGray
                    .edgesIgnoringSafeArea(.all)
                
                if viewModel.progress == .inProcess {
                    // 진행상황 표시
                    CustomProgressView
                } else {
                    TrackableScrollView(reachedBottom: self.$isBottom, reachAction: {}) {
                        // 플레이스 리스트
                        VStack(spacing: 7) {
                            if viewModel.places.isEmpty {
                                Text("아직 플레이스가 없어요\n지도에서 플레이스를 추가해보세요!")
                                    .multilineTextAlignment(.center)
                                    .font(.basic.normal15)
                                    .padding(.vertical, 40)
                                    .foregroundColor(.gray)
                                
                                AdditionButton
                                Spacer()
                            } else {
                                ForEach(viewModel.places, id: \.id) { wrapper in
                                    let place = wrapper.placeInfo
                                    // MARK: - 카드 뷰
                                    LightCardView(place: place, isFavorite: true, starAction: {
                                        guard let index = viewModel.places.firstIndex(of: wrapper) else { return }
                                        var updatedPlaces = viewModel.places
                                        updatedPlaces.remove(at: index)
                                        let ids = updatedPlaces.map{ $0.placeInfo.id }
                                        
                                        listManager.editPlacesList(listID: viewModel.list.identifier,
                                                                   placeIDs: ids) { result in
                                            DispatchQueue.main.async {
                                                switch result {
                                                case true:
                                                    viewModel.progress = .finished
                                                    _ = withAnimation(.spring()) {
                                                        viewModel.places.remove(at: index)
                                                    }
                                                    return
                                                case false:
                                                    viewModel.progress = .failed
                                                    showWarning = true
                                                    return
                                                }
                                            }
                                        }
                                    })
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.white)
                                            .shadow(color: .gray.opacity(0.15), radius: 20, y: 2)
                                    )
                                }
                                
                                AdditionButton
                                    .padding(.top, 20)
                                    .padding(.bottom, 45)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 15)
                    }
                }
            }
        }
        .alert(isPresented: $showWarning) {
            Alert(title: Text("오류 발생"), message: Text("알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요."), dismissButton: .default(Text("Close")))
        }
        .showAlert(show: $showEditPopup, alert: RegisterNewListAlertView(submitAction: {
            // 수정 팝업 띄우기
            withAnimation(.spring()) {
                showEditPopup = false
            }
        }, requestType: .patch(id: viewModel.list.identifier), completion: { result in
            DispatchQueue.main.async {
                switch result {
                case true:
                    withAnimation(.spring()) {
                        showEditPopup = false
                    }
                    return
                case false:
                    // TODO: Do something
                    showWarning = true
                    return
                }
            }
        })
            .environmentObject(listManager)
        )
        .navigationBarHidden(true)
    }
}

extension PlaceListDetailView {
    var AdditionButton: some View {
        Button(action: {
            self.selection = .map
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack(alignment: .center) {
                Spacer()
                Text("+ 플레이스 추가하기")
                    .font(.basic.normal15)
                    .padding(1)
                Spacer()
            }
        }
        .frame(height: 52)
        .foregroundColor(.gray)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(.gray))
    }
}

//struct PlaceListDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaceListDetailView()
//    }
//}
