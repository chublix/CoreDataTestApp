//
//  RestaurantsNetwork.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/15/21.
//

import RxSwift

protocol RestaurantsNetwork: AnyObject {
    func fetch() -> Single<[RestaurantDTO]>
}


final class RestaurantsNetworkImpl: RestaurantsNetwork {
    
    private let url = URL(string: "https://www.mocky.io/v2/54ef80f5a11ac4d607752717")!
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func fetch() -> Single<[RestaurantDTO]> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return urlSession.dataTask(with: request)
            .compactMap { $0 }
            .decode([RestaurantDTO].self)
    }
    
}
