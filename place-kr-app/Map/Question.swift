//import SwiftUI
//import NMapsMap
//
//class TempViewModel: ObservableObject {
//    @Published var coord: (Double, Double) = (100, 100)
//}
//
//struct MapView: View {
//    @ObservedObject var temp = TempViewModel()
//
//    @State var xx = false
//    var body: some View {
//        ZStack {
//            UIMapView(coord: temp.coord)
//                .edgesIgnoringSafeArea(.vertical)
//
//            Button(action: {temp.coord = (126.978, 37.566)}) {
//                Text("Move to 126.978, 37.566")
//            }
//            .zIndex(1)
//        }
//    }
//}
//
//struct UIMapView: UIViewRepresentable {
//    let view = NMFNaverMapView()
//    let coord: (Double, Double)
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(coord: coord)
//    }
//
//    func makeUIView(context: Context) -> NMFNaverMapView {
//        view.showZoomControls = false
//        view.mapView.positionMode = .direction
//        view.mapView.zoomLevel = 17
//
//        view.mapView.addCameraDelegate(delegate: context.coordinator)
//
//        return view
//    }
//
//    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
//        let c = NMGLatLng(lat: coord.1, lng: coord.0)
//        print("Coord set to \(c.lat) \(c.lng)")
//        moveTo(c)
//    }
//
//    func moveTo(_ coord: NMGLatLng) {
//        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
//        view.mapView.moveCamera(cameraUpdate) { isCancelled in
//            if isCancelled {
//                print("카메라 이동 취소")
//            } else {
//                print("카메라 이동 완료")
//            }
//        }
//    }
//
//    class Coordinator: NSObject, NMFMapViewCameraDelegate {
//        let coord: (Double, Double)
//
//        init(coord: (Double, Double)) {
//            self.coord = coord
//        }
//
//        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
//            print("카메라 변경 - reason: \(reason)")
//        }
//
//        func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
//            print("카메라 변경 - reason: \(reason)")
//        }
//    }
//}
