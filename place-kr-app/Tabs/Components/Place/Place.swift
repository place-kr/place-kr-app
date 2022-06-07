//
//  Place.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import Foundation

struct KakaoPlaceResponse: Codable {
    let documents: [Document]
    let meta: Meta
    
    struct Document: Codable {
        let id: String
        let textAddress: String
        let roadAddress: String
        let name: String
        let url: String
        let x: String
        let y: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case textAddress = "address_name"
            case roadAddress = "road_address_name"
            case name = "place_name"
            case url = "place_url"
            case x
            case y
        }
    }
    
    struct Meta: Codable {
        let isEnd: Bool
        
        enum CodingKeys: String, CodingKey {
            case isEnd = "is_end"
        }
    }
}

struct KakaoPlaceInfo: Identifiable {
    private let document: KakaoPlaceResponse.Document
    
    var id: String {
        return document.id
    }
    
    var textAddress: String {
        return document.textAddress
    }
    
    var roadAddress: String {
        return document.roadAddress
    }
    
    var name: String {
        return document.name
    }
    
    var url: URL {
        return URL(string: document.url)!
    }
    
    var coordString: (String, String) {
        return (document.x, document.y)
    }
    
    var coord: (Double, Double) {
        let x: Double = Double(document.x) ?? 0
        let y: Double = Double(document.y) ?? 0
        
        return (x, y)
    }
    
    init(document: KakaoPlaceResponse.Document) {
        self.document = document
    }
}

protocol PlaceInformation {
    var identifier: String { get }
    var name: String { get }
    var x: String { get }
    var y: String { get }
    var isFavorite: Bool { get }
    var thumbnailUrl: String? { get }
    var phone: String? { get }
    var address: String? { get }
    var category: String? { get }
    var saves: Int? { get }
}

extension PlaceInformation {
    var phone: String? { get {nil} }
    var address: String? { get {nil} }
    var thumbnailUrl: String? { get {nil} }
    var category: String? { get {nil} }
    var saves: Int? { get {nil} }
}

struct PlaceResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PlacePin]
    
    enum Condingkeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
    
    struct PlacePin: Codable, PlaceInformation {
        let identifier: String
        let name: String
        let registrant: Registrant
        let thumbnailUrl: String
        let isFavorite: Bool
        let x: String
        let y: String
        
        enum CodingKeys: String, CodingKey {
            case identifier, name, registrant, x, y
            case thumbnailUrl = "thumbnail_url"
            case isFavorite = "is_in_my_list"
        }
    }
    
    struct Registrant: Codable {
        let nickname: String
    }
}

/// 플레이스 정보를 담은 데이터 타입입니다
struct PlaceInfo {
    private let document: PlaceInformation
    
    var id: String {
        return document.identifier
    }
    
    var name: String {
        return document.name
    }
    
    var lonlat: LonLat {
        let x: Double = Double(document.x) ?? 0
        let y: Double = Double(document.y) ?? 0
        
        return LonLat(lon: x, lat: y)
    }
    
    var phone: String {
        guard let phone = document.phone else {
            return "전화번호 없음"
        }
        return phone
    }
    
    var address: String {
        guard let address = document.address else {
            return "주소정보 없음"
        }
        return address
    }
    
    var imageUrl: URL? {
        guard let imageUrl = document.thumbnailUrl else {
            return nil
        }
        return URL(string: imageUrl)
    }
    
    var category: String {
        guard let category = document.category else {
            return "카테고리 없음"
        }
        return category
    }
    
    var saves: Int {
        guard let saves = document.saves else {
            return 0
        }
        return saves
    }
    
    var isFavorite: Bool {
        return document.isFavorite
    }
    
    init(document: PlaceResponse.PlacePin) {
        self.document = document
    }
    
    init(document: OnePlaceResponse) {
        self.document = document
    }
}

extension PlaceInfo {
    struct LonLat {
        let lon: Double
        let lat: Double
    }
}


struct MultiplePlaceResponse: Codable {
    let results: [OnePlaceResponse]
    
    enum CodingKeys: CodingKey {
        case results
    }
}

struct OnePlaceResponse: Codable, PlaceInformation {
    let identifier: String
    let name: String
    let x: String
    let y: String
    let savedList: [String]
    let isFavorite: Bool = false

    let phone: String?
    let address: String?
    let thumbnailUrl: String?
    let category: String?
    let saves: Int?

    enum CodingKeys: String, CodingKey {
        case identifier, name, phone, address, x, y, category
        case savedList = "saved_in_my_lists"
        case thumbnailUrl = "thumbnail_url"
        case saves = "saves_count"
    }
}
 
