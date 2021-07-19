//
//  RestaurantDTO.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/18/21.
//

import Foundation

struct RestaurantDTO {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}

extension RestaurantDTO: EntityDTO {
    
    static var entitiName: String { "Restaurant" }
    
    enum DecodingKeys: String, CodingKey {
        case name = "Name"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
    enum EncodingKeys: String, CodingKey {
        case name
        case address
        case latitude
        case longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(latitude, forKey: .latitude)
    }
}
