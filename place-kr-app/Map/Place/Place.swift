//
//  Place.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/02/07.
//

import Foundation

struct PlaceResponse: Codable {
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
    
    struct Meta: Codable {}
}

struct PlaceInfo {
    private let document: PlaceResponse.Document
    
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
    
    var coord: (Double, Double) {
        let x: Double = Double(document.x) ?? 0
        let y: Double = Double(document.y) ?? 0
        
        return (x, y)
    }
    
    init(document: PlaceResponse.Document) {
        self.document = document
    }
}
