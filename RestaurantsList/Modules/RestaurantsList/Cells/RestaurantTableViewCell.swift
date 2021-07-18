//
//  RestaurantTableViewCell.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/18/21.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    
    func setup(with model: Restaurant) {
        nameLabel.text = model.name
        addressLabel.text = model.address
    }
    
}
