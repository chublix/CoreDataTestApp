//
//  RestaurantsListViewController.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/15/21.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class RestaurantsListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var mapView: MKMapView!
    
    private let cellIdentifier = "RestaurantTableViewCell"
    private let disposeBag = DisposeBag()
    
    var viewModel: RestaurantsListViewModel = .make()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindModel()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = .init()
        mapView.delegate = self
    }
    
    private func bindModel() {
        viewModel.restaurants.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) { row, model, cell in
            (cell as? RestaurantTableViewCell)?.setup(with: model)
        }.disposed(by: disposeBag)
        viewModel.start()
        viewModel.restaurants.subscribe(onNext: { [weak mapView] restaurants in
            if let annotations = mapView?.annotations {
                mapView?.removeAnnotations(annotations)
            }
            mapView?.addAnnotations(restaurants.map(Annotation.init(restaurant:)))
        }).disposed(by: disposeBag)
    }

}

extension RestaurantsListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapView.dequeueReusableAnnotationView(withIdentifier: "annotation", for: annotation)
    }
}
