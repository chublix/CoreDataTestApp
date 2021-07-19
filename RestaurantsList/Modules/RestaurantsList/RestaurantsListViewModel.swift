//
//  RestaurantsListViewModel.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/15/21.
//

import CoreData
import RxSwift
import CoreLocation

final class RestaurantsListViewModel: NSObject {
    
    //MARK: Dependencies
    private let networkService: RestaurantsNetwork
    private let coreDataStack: CoreDataStack
    private let locationService: LocationService
    
    //MARK: Internal properties
    private lazy var fetchedResultsController: NSFetchedResultsController<Restaurant> = {
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller: NSFetchedResultsController<Restaurant> = .init(
            fetchRequest: request,
            managedObjectContext: coreDataStack.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: Outs
    let restaurants: PublishSubject<[Restaurant]> = .init()
    let errorMessage: PublishSubject<String> = .init()
    
    init(networkService: RestaurantsNetwork, coreDataStack: CoreDataStack, locationService: LocationService) {
        self.networkService = networkService
        self.coreDataStack = coreDataStack
        self.locationService = locationService
        super.init()
    }
    
    func start() {
        restaurants.onNext(fetchedResultsController.fetchedObjects ?? [])
        networkService.fetch().subscribe(onSuccess: { [weak self] restaurants in
            self?.coreDataStack.insert(restaurants)
        }).disposed(by: disposeBag)
    }
    
    func addRestaurantWith(name: String, address: String) {
        locationService.getCurrent().subscribe(onSuccess: { [weak self] coordinate in
            let restaurant = RestaurantDTO(
                name: name,
                address: address,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude)
            self?.coreDataStack.insert(restaurant)
        }, onFailure: { [weak self] error in
            switch (error as? LocationServiceError) {
            case .some(.denied):
                self?.errorMessage.onNext("Access to location is denied.\nPlease enable it in application settings.")
            case .some(.noData):
                self?.errorMessage.onNext("No avaiable location data.")
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    
}

extension RestaurantsListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let objects = fetchedResultsController.fetchedObjects else { return }
        restaurants.onNext(objects)
    }
}


extension RestaurantsListViewModel {
    class func make() -> RestaurantsListViewModel {
        let networkService = RestaurantsNetworkImpl(urlSession: .shared)
        let locationService = LocationServiceImpl()
        return RestaurantsListViewModel(networkService: networkService,
                                        coreDataStack: .shared,
                                        locationService: locationService)
    }
}
