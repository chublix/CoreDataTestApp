//
//  Annotation.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/18/21.
//

import MapKit

final class Annotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: restaurant.latitude, longitude: restaurant.longitude)
    }
    
    var title: String? { restaurant.name }
    
    var subtitle: String? { restaurant.address }
    
    //MARK: Internal property
    private let restaurant: Restaurant
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }
}
