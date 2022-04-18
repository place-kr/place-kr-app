//
//  LocationManager.swift
//  Weatherman
//
//  Created by 이영빈 on 2022/02/04.
//

import Foundation
import CoreLocation
import Combine

// TODO: Permission handling

/// 현위치를 계산 및 저장하는 클래스입니다. shared 싱글톤 객체를 이용해서 접근할 수 있습니다. 
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    static let shared = LocationManager()
    
    @Published var locationName: String?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var currentCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(37.578472), longitude: CLLocationDegrees(126.97727))

    override init() {
        super.init()
        DispatchQueue.global(qos: .utility).async {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestLocation()
        }
    }
    
    /// 현위치로 상태를 변경합니다. 모종의 이유로 현위치가 변했을 때 수동으로 조정합니다.
    func setCurrentLocation() {
        locationManager.requestLocation()
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            print("Location auth is not recieved")
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: 권한 설정 후 위치 재설정
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.locationStatus = status
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // 현위치 업데이트 
//        self.currentCoord = location.coordinate
    }
}
