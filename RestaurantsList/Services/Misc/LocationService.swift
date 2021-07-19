//
//  LocationService.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/19/21.
//

import CoreLocation
import RxSwift
import RxRelay

protocol LocationService: AnyObject {
    func getCurrent() -> Single<CLLocationCoordinate2D>
}

enum LocationServiceError: Error {
    case denied
    case noData
}

final class LocationServiceImpl: NSObject, LocationService {
    
    private var result: ReplaySubject<CLLocationCoordinate2D> = .createUnbounded()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    func getCurrent() -> Single<CLLocationCoordinate2D> {
        let status = CLLocationManager.authorizationStatus()
        handle(status: status)
        return result.asSingle()
    }
    
    private func handle(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse,
             .authorizedAlways:
            guard let coordinate = locationManager.location?.coordinate else {
                result.onError(LocationServiceError.noData)
                return
            }
            result.onNext(coordinate)
            result.onCompleted()
        case .denied:
            result.onError(LocationServiceError.denied)
        default:
            break
        }
    }
    
}

extension LocationServiceImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handle(status: status)
    }
}
