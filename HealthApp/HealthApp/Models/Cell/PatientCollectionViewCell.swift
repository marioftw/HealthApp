//
//  PatientCollectionViewCell.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class PatientCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var patientImageView: UIImageView!
    @IBOutlet weak var patientName: UILabel!
    
    override func awakeFromNib() {
        patientImageView.setRounded(bordedColor: UIColor.clear, borderWitdht: 0)
    }
    
}
