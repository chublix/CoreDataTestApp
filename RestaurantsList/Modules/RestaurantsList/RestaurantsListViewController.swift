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
    private let annotationIdentifier = "annotation"
    private let disposeBag = DisposeBag()
    
    var viewModel: RestaurantsListViewModel = .make()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupMapView()
        bindModel()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = .init()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationIdentifier)
    }
    
    private func bindModel() {
        viewModel.restaurants.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) { row, model, cell in
            (cell as? RestaurantTableViewCell)?.setup(with: model)
        }.disposed(by: disposeBag)
        viewModel.restaurants.subscribe(onNext: { [weak mapView] restaurants in
            if let annotations = mapView?.annotations {
                mapView?.removeAnnotations(annotations)
            }
            let annotations = restaurants.map(Annotation.init(restaurant:))
            mapView?.addAnnotations(annotations)
        }).disposed(by: disposeBag)
        viewModel.errorMessage.subscribe(onNext: showError(with:)).disposed(by: disposeBag)
        viewModel.start()
    }
    
    @IBAction private func add(_ sender: Any) {
        let alert = UIAlertController(title: "Add new restaurant", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name" }
        alert.addTextField { $0.placeholder = "Address" }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Add", style: .default, handler: {  [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty else { return }
            guard let address = alert.textFields?[1].text, !address.isEmpty else { return }
            self?.viewModel.addRestaurantWith(name: name, address: address)
        }))
        present(alert, animated: true)
    }
}

extension RestaurantsListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier,
                                                                   for: annotation)
        annotationView.image = .init(named: "map-annotation")
        annotationView.canShowCallout = true
        return annotationView
    }
}

extension RestaurantsListViewController {
    
    private func showError(with message: String) {
        let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
}
