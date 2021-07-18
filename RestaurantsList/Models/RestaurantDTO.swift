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

extension RestaurantDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
}
