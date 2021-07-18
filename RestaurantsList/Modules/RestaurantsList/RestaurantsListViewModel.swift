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
    
    //MARK: Internal properties
    private lazy var fetchedResultsController: NSFetchedResultsController<Restaurant> = {
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller: NSFetchedResultsController<Restaurant> = .init(
            fetchRequest: request,
            managedObjectContext: coreDataStack.persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: Outs
    let restaurants: PublishSubject<[Restaurant]> = .init()
    
    init(networkService: RestaurantsNetwork, coreDataStack: CoreDataStack) {
        self.networkService = networkService
        self.coreDataStack = coreDataStack
        super.init()
    }
    
    func start() {
        restaurants.onNext(fetchedResultsController.fetchedObjects ?? [])
        networkService.fetch().subscribe(onSuccess: { [weak self] restaurants in
            self?.putDataIntoStorage(restaurants: restaurants)
        }).disposed(by: disposeBag)
    }
    
    private func putDataIntoStorage(restaurants: [RestaurantDTO]) {
        coreDataStack.persistentContainer.viewContext.perform { [weak self] in
            do {
                let data = try JSONEncoder().encode(restaurants)
                let objects = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                let insert = NSBatchInsertRequest(entityName: "Restaurant", objects: objects ?? [])
                try self?.coreDataStack.persistentContainer.viewContext.execute(insert)
//                try context.save()
            } catch {
                debugPrint(error)
            }
            
            self?.coreDataStack.saveContext()
        }
    }
    
    func addRestaurantWith(name: String, address: String, coordinate: CLLocationCoordinate2D) {
        let restaurant = Restaurant(context: coreDataStack.persistentContainer.viewContext)
        restaurant.name = name
        restaurant.address = address
        restaurant.latitude = coordinate.latitude
        restaurant.longitude = coordinate.longitude
        coreDataStack.saveContext()
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
        return RestaurantsListViewModel(networkService: networkService, coreDataStack: .shared)
    }
}
