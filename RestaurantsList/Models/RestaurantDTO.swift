//
//  RestaurantDTO.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/18/21.
//

import Foundation

struct RestaurantDTO: Decodable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}
