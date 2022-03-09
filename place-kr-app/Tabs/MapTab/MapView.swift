//
//  MapView.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/30.
//

import SwiftUI
import BottomSheet

import Combine
class PlaceInfoManager: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var placeInfo: PlaceInfo?
    @Published var temp = false
    var currentPlaceID: String?
    let uuid = UUID()

    func fetchInfo(id placeID: String) {
        PlaceSearchManager.getPlacesByIdentifier(placeID)
            .receive(on: DispatchQueue.main)
            .map({ PlaceInfo(document: $0) })
            .sink(receiveCompletion: { result in
                print(result)
                switch result {
                case .failure(let error):
                    print("Error happend: \(error)")
                case .finished:
                    print("PlaceInfoManager successfully fetched")
                }
            }, receiveValue: { value in
                print("\(self.uuid) PlaceInfoManager: \(value)")
                self.placeInfo = value
            })
            .store(in: &subscriptions)
        
        temp = true
    }
    
    init() {    }
}

struct MapView: View {
    @StateObject var mapViewModel = UIMapViewModel() // TODO: ??? 왜 됨?
    @StateObject var placeInfoManager = PlaceInfoManager()
    
    @State var activeSheet: ActiveSheet = .placeInfo
    @State var bottomSheetPosition: SheetPosition = .hidden
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                /// 네이버 맵
                UIMapView(viewModel: mapViewModel, markerAction: {
                    withAnimation(springAnimation) {
                        self.bottomSheetPosition = .bottom
                        self.activeSheet = .placeInfo
                    }
                })
                    .environmentObject(placeInfoManager)
                    .edgesIgnoringSafeArea(.vertical)
                
                VStack {
                    Spacer()
                     
                    if mapViewModel.mapNeedsReload {
                        // TODO: 맵 리로드 버튼 - 나중에 수정
                        Button(action: {
                            // fetch -> make marker -> draw marker
                            mapViewModel.fetchPlaces(in: mapViewModel.currentBounds)
                            withAnimation(.spring()) {
                                mapViewModel.mapNeedsReload = false
                            }
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.black)
                                .shadow(radius: 5)
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
                .padding(.bottom, 15)
                .zIndex(1)
                
                VStack(spacing: 10) {
                    /// 검색창
                    HStack(spacing: 11) {
                        SearchField
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                            .padding(.leading, 15)
                        
                        NotificationView()
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                            .padding(.trailing, 15)
                    }
                    
                    /// 검색창 및 Sheet view 버튼 + Sheet pop 용 빈 뷰
                    HStack {
                        EntirePlaceButton
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)

                        MyPlaceButton
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    Spacer()
                }
                .zIndex(1)
            }
            .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                         options: [.animation(springAnimation), .background(AnyView(Color.white)), .cornerRadius(10),
                                   .allowContentDrag, .noBottomPosition, .swipeToDismiss,
                                   .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: -5)],
                         headerContent: {
                SheetHeader
            }) {
                SheetContent
                    .padding([.horizontal, .top])
            }
            .navigationBarHidden(true)
        }
    }
}

extension MapView {
    enum ActiveSheet {
        case myPlace, entire, placeInfo
    }
    
    var SheetHeader: some View {
        VStack(alignment: .leading) {
            Text("Wuthering Heights")
                .font(.title).bold()
            
            sheetView(active: activeSheet)
        }
    }
    
    var SheetContent: some View {
        VStack(spacing: 0) {
            Text("This tumultuous tale of life in a bleak farmhouse on the Yorkshire moors is a popular set text for GCSE and A-level English study, but away from the demands of the classroom it’s easier to enjoy its drama and intensity. Populated largely by characters whose inability to control their own emotions...")
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Button(action: {}, label: {
                    Text("Read More")
                        .padding(.horizontal)
                })
                
                Spacer()
                
                Button(action: {}, label: {
                    Image(systemName: "bookmark")
                })
            }
            .padding(.top)
            
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder
    func sheetView(active: ActiveSheet) -> some View {
        switch active {
        case .myPlace:
            Text("My place")
        case .entire:
            Text("전체")
        case .placeInfo:
            if let placeInfo = placeInfoManager.placeInfo {
                LargePlaceCardView(of: placeInfo)
            } else {
                Text("Yet.")
//                ProgressView(style: UIActivityIndicatorView.Style.medium)
            }
        }
    }
    
    var SearchField: some View {
        ThemedTextField($searchText, "장소를 입력하세요", bgColor: .white, isStroked: false, position: .leading, buttonName: "magnifyingglass", buttonColor: .black) {
            print("tapped")
        }
    }
    
    var EntirePlaceButton: some View {
        func doShowSheet() {
            withAnimation(springAnimation) {
                bottomSheetPosition = .bottom
            }
        }
        
        return Button(action: { doShowSheet() }) {
            Text("전체")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(activeSheet == .entire ? .gray : .white))
    }
    
    var MyPlaceButton: some View {
        func doShowSheet() {
            withAnimation(springAnimation) {
                activeSheet = .myPlace
                bottomSheetPosition = .bottom
            }
        }
        
        return Button(action: { doShowSheet() }) {
            Text("My")
        }
        .buttonStyle(CapsuledButtonStyle())
        .background(Capsule().fill(activeSheet == .myPlace ? .gray : .white))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
