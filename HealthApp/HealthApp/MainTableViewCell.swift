//
//  MainTableViewCell.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var cellBackground: UIImageView!
    @IBOutlet weak var patientsQuantityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var patientsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
