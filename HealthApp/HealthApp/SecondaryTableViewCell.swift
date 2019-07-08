//
//  SecondaryTableViewCell.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class SecondaryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var patientImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        patientImageView.setRounded(bordedColor: UIColor.clear, borderWitdht: 0)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
