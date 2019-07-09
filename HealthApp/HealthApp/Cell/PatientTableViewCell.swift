//
//  PatientTableViewCell.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class PatientTableViewCell: UITableViewCell {

    @IBOutlet var patientImageView: UIImageView!
    @IBOutlet var patientNameLabel: UILabel!
    @IBOutlet var patientGenderLabel: UILabel!
    @IBOutlet var patientAgeLabel: UILabel!
    override func awakeFromNib() {
        patientImageView.setRounded(bordedColor: UIColor.clear, borderWitdht: 0)
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
