//
//  LocationManager.swift
//  Weatherman
//
//  Created by 이영빈 on 2022/02/04.
//

import Foundation
import CoreLocation
import Combine

struct LocationResponse: Decodable {
    let documents: [Document]
    
    struct Document: Decodable {
        let fullAddress: String
        let city: String
        let county: String
        
        enum CodingKeys: String, CodingKey {
            case fullAddress = "address_name"
            case city = "region_2depth_name"
            case county = "region_3depth_name"
        }
    }
}

// TODO: Permission handling

/// 현위치를 계산 및 저장하는 클래스입니다. shared 싱글톤 객체를 이용해서 접근할 수 있습니다. 
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    static let shared = LocationManager()
    
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var currentCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(37.578472), longitude: CLLocationDegrees(126.97727))
    @Published var currentLocationName: String?

    override init() {
        super.init()
        
        DispatchQueue.global(qos: .utility).async {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
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
        self.currentCoord = location.coordinate
//        //
//        let city = decoded.documents.first?.city
//        let county = decoded.documents.first?.county
//
//        DispatchQueue.main.async {
//            if let city = city, let county = county {
//                self.currentLocationName = city + " " + county
//            }
//        }
        
    }
    
    func getLocationDescription(location: CLLocation, completion: @escaping (LocationResponse?) -> ()) {
        // Network request
        let queryItem = [
            URLQueryItem(name: "x", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "y", value: "\(location.coordinate.latitude)")
        ]
        
        guard let request = authorizedRequest(method: "GET", api: "/reverse_geocoding", queryItems: queryItem) else {
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            if let response = response as? HTTPURLResponse,
                !((200...300).contains(response.statusCode)) {
                print("Error in response. May be a network error.\(response as Any)")
                return
            }
            
            guard let data = data else {
                return
            }

            do {
                let decoded = try JSONDecoder().decode(LocationResponse.self, from: data)
                completion(decoded)
            } catch(let error) {
                completion(nil)
                print(error)
            }
        }
        .resume()
    }
}
