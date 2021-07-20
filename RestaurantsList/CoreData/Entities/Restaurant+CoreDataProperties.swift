//
//  Restaurant+CoreDataProperties.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/15/21.
//
//

import Foundation
import CoreData


extension Restaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension Restaurant : Identifiable {

}
