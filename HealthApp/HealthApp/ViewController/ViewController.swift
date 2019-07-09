//
//  ViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var secondCollectionView: UICollectionView!
    
    var names = ["John","Eliza", "Paul", "Isobele", "Fred", "George"]
    var images: [UIImage] = [#imageLiteral(resourceName: "male1"),#imageLiteral(resourceName: "profile_picture"),#imageLiteral(resourceName: "male4"),#imageLiteral(resourceName: "female-1"),#imageLiteral(resourceName: "male2"),#imageLiteral(resourceName: "male3")]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
         return true
    }
    
    @IBAction func seeAllButtonPressed(_ sender: UIButton) {
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainTableViewCell
            cell.nameLabel.text = "Dr. Smith"
            cell.patientsQuantityLabel.text = "You've got \(names.count) patients today"
            self.collectionView = cell.patientsCollectionView
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecondaryCell", for: indexPath) as! SecondaryTableViewCell
            self.secondCollectionView = cell.collectionView
            cell.titleLabel.text = "Upcoming Patient"
            cell.patientNameLabel.text = names.first
            cell.patientImageView.image = images.first
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicBigTableViewCell
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9994794726, green: 0.9222456217, blue: 0.8273747563, alpha: 1)
            cell.titleLabel.textColor = #colorLiteral(red: 0.14901492, green: 0.3072064519, blue: 0.4399905205, alpha: 1)
            cell.subtitleLabel.textColor = #colorLiteral(red: 0.1918424666, green: 0.3328226805, blue: 0.4559432268, alpha: 1)
            cell.titleLabel.text = "My Patients"
            cell.subtitleLabel.text = "Look in a list with all your patients"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicBigTableViewCell
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9723386168, green: 0.5278795958, blue: 0.4031898975, alpha: 1)
            cell.titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.titleLabel.text = "My Profile Info"
            cell.subtitleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.subtitleLabel.text = "Change your basic information"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            performSegue(withIdentifier: "showMyPatientsVC", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 || indexPath.row == 3 {
            return 200.0
        }
        
        return 450.0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return 3
        }
        return names.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCell", for: indexPath) as! InformationCollectionViewCell
            switch indexPath.row {
            case 0:
                cell.descriptionLabel.text = "Age"
                cell.valueLabel.text = "28"
            case 1:
                cell.descriptionLabel.text = "Weight"
                cell.valueLabel.text = "170lb"
            default:
                cell.descriptionLabel.text = "Height"
                cell.valueLabel.text = "5'9"
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientCell", for: indexPath) as! PatientCollectionViewCell
        cell.patientName.text = names[indexPath.row]
        cell.patientImageView.image = images[indexPath.row]
        return cell
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0);
    }*/
    
}


