//
//  PatientProfileViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class PatientProfileViewController: UIViewController {

    var profileCollectionView: UICollectionView!
    var infoCollecitonView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setMinimal()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1918424666, green: 0.3328226805, blue: 0.4559432268, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

extension PatientProfileViewController: UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! SecondaryTableViewCell
            cell.patientNameLabel.text = "Jeff Moon"
            cell.patientImageView.image = #imageLiteral(resourceName: "male1")
            self.profileCollectionView = cell.collectionView
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
        self.infoCollecitonView = cell.collectionView
        
        switch indexPath.row {
        case 1:
            cell.titleLabel.text = "Hearth"
            cell.statusCardLabel.text = "Healthy"
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.5908090472, green: 0.9698002934, blue: 0.7920762897, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.9995251298, green: 0.7069824338, blue: 0.6729323268, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.9485823512, green: 0.7537450194, blue: 0.7276101708, alpha: 1)
        case 2:
            cell.titleLabel.text = "Weight"
            cell.statusCardLabel.text = "Healthy"
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.5908090472, green: 0.9698002934, blue: 0.7920762897, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.3993943036, green: 0.5611467361, blue: 0.5224861503, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.4834083319, green: 0.6784313725, blue: 0.6100088954, alpha: 1)
        case 3:
            cell.titleLabel.text = "Height"
            cell.cardInfo.isHidden = true
            cell.cardView.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.339291418, alpha: 1)
        case 4:
            cell.titleLabel.text = "Sleep"
            cell.statusCardLabel.text = "Wrong"
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.3150302839, green: 0.5, blue: 0.3266408257, alpha: 1)
        case 5:
            cell.titleLabel.text = "Alimentation"
            cell.statusCardLabel.text = "Healthy"
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.5908090472, green: 0.9698002934, blue: 0.7920762897, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.14901492, green: 0.3072064519, blue: 0.4399905205, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.14901492, green: 0.3440370624, blue: 0.3986850792, alpha: 1)
        default:
            cell.titleLabel.text = "Exercise"
            cell.statusCardLabel.text = "Lower"
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.5, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 250.0
        if indexPath.row == 0 {
            height = 330.0
        }
        
        return height
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCell", for: indexPath) as! InformationCollectionViewCell
        if collectionView.tag == 0 {
            if indexPath.row == 0 {
                cell.descriptionLabel.text = "Age"
                cell.valueLabel.text = "28"
            } else if indexPath.row == 1 {
                cell.descriptionLabel.text = "Weight"
                cell.valueLabel.text = "170lb"
            } else {
                cell.descriptionLabel.text = "Height"
                cell.valueLabel.text = "5'9\""
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCell", for: indexPath) as! InformationCollectionViewCell
            if indexPath.row == 0 {
                cell.descriptionLabel.text = "BPM"
                cell.valueLabel.text = "68"
            } else if indexPath.row == 1 {
                cell.descriptionLabel.text = "Last Record"
                cell.valueLabel.text = "1, 12"
            } else {
                cell.descriptionLabel.text = "Blod Type"
                cell.valueLabel.text = "A+"
            }
            
            return cell
        }
    }
    
   
}
