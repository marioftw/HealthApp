//
//  InfoTableViewCell.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet var cardView: CardView!
    @IBOutlet weak var statusCardLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var cardInfo: CardView!
    
    @IBOutlet var firstItemLabel: UILabel!
    @IBOutlet var firstDetailLabel: UILabel!
    @IBOutlet var secondItemLabel: UILabel!
    @IBOutlet var secondDetailLabel: UILabel!
    @IBOutlet var thirdItemLabel: UILabel!
    @IBOutlet var thirdDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
