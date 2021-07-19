//
//  EntityDTO.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/19/21.
//

import Foundation

protocol EntityDTO: Codable {
    static var entitiName: String { get }
}
