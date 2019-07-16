//
//  ProfileViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/5/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileViewController: UIViewController{
    let realm = try? Realm()
    var patient: Patient?
    var collectionView: UICollectionView!
    var backgroundImages: [UIImage] = [#imageLiteral(resourceName: "hardBlueGradient"), #imageLiteral(resourceName: "blueGradient"), #imageLiteral(resourceName: "purpleGradient"), #imageLiteral(resourceName: "pinkGradient")]
    var optionPressed = -1
    var todaySteps = 0
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPatient()
        setAllDetails()
        NotificationCenter.default.addObserver(self, selector: #selector(setPatientBasicData), name: Notification.Name("healthKitAuth"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func scanQRButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add a Doctor", message: "How do you want to add a new doctor?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Scan DoctorID", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Show my PatientID", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Settings", message: "Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func setPatientBasicData() {
        let (age, bloodType, biologicalSex) = HealthKitService.shared.getPacientBasicData()
        let readableBloodType = HealthKitService.shared.getReadable(bloodType: bloodType?.bloodType)
        let readableBiologicalSex = HealthKitService.shared.getReadable(biologicalSex: biologicalSex)
        let finalAge = age ?? 0
        
        do {
            try realm?.write {
                
                if patient?.age != finalAge {
                    patient?.age = finalAge
                }
                
                if patient?.biologicalSex != readableBiologicalSex {
                    patient?.biologicalSex = readableBiologicalSex
                }
                
                if patient?.bloodType != readableBloodType {
                    patient?.bloodType = readableBloodType
                }
                
                realm?.add(patient!)
            }
        } catch {
            print("Error Saving: \(error.localizedDescription)")
        }
        
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func setPatient() {
        if let myPatient = realm?.objects(Patient.self).first {
            self.patient = myPatient
        } else {
            self.patient = Patient(uid: "UID")
            do {
                try realm?.write {
                    realm?.add(patient!)
                }
            } catch {
                print("Error Saving user: \(error.localizedDescription)")
            }
        }
    }
    
    func setAllDetails() {
        HealthKitService.shared.weightRecords(from: Date(timeIntervalSince1970: TimeInterval()), to: Date(), patient: patient!)
        HealthKitService.shared.heightRecords(from:Date(timeIntervalSince1970: TimeInterval()), to: Date(), patient: patient!)
        HealthKitService.shared.getSleepAnalysis(from: Date(timeIntervalSince1970: TimeInterval()), to: Date(), patient: patient!)
        HealthKitService.shared.getHearthRate(from: Date(timeIntervalSince1970: TimeInterval()), to: Date(), patient: patient!)
        HealthKitService.shared.getActiveEnergy(patient: patient!)
        HealthKitService.shared.getStepsCount(forSpecificDate: Date()) { (steps) in
            self.todaySteps = Int(steps)
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
            cell.nameLabel.text = "Awesome Name"
            //cell.nameLabel.text = patient?.firstName
            cell.genderLabel.text = patient?.biologicalSex
            cell.imageView?.setRounded()
            //cell.imageView?.image = UIImage(named: "profile_picture")
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionViewTableViewCell
            self.collectionView = cell.collectionView
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardTableViewCell
            cell.selectionStyle = .none
            if indexPath.row == 2 {
                cell.titleLabel.text = "Calories Burned"
                cell.topicIcon.image = UIImage(named: "burn-icon")!
                cell.descriptionLabel.text = "This is the count of calories burned with your activity throughout the day"
                print(patient?.workoutRecords.last?.startDate as Any)
                cell.quantityLabel.text = "\(patient!.workoutRecords.last?.calories ?? 0)"
            } else if indexPath.row == 3 {
                cell.cardView.backgroundColor = #colorLiteral(red: 0.2653386891, green: 0.2729498446, blue: 0.6093763709, alpha: 1)
                cell.titleLabel.text = "Hours sleeping"
                cell.topicIcon.image = UIImage(named: "moon-icon")!
                cell.descriptionLabel.text = "It takes the count of the hours in bed of the last night"
                cell.quantityLabel.text = "\(patient!.sleepRecords.last?.hoursSleeping ?? "0 h")"
            } else if indexPath.row == 4 {
                cell.cardView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                cell.titleLabel.text = "Calories today"
                cell.topicIcon.image = UIImage(named: "food-icon")!
                cell.descriptionLabel.text = "Counting the calories consumed throughout the day, nutrition is important"
                //cell.quantityLabel.text = "\(patient!.workoutRecords.last?.calories ?? 0)"
                cell.quantityLabel.text = "1500"
            } else if indexPath.row == 5 {
                cell.cardView.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                cell.titleLabel.text = "Hearth BPM"
                cell.topicIcon.image = UIImage(named: "hearth-icon")!
                cell.descriptionLabel.text = "A record of beats per minute is recorded in different activities"
                cell.quantityLabel.text = "\(patient!.hearthRecords.last?.bpm ?? 0)"
            } else if indexPath.row == 6 {
                cell.cardView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
                cell.titleLabel.text = "Nevus Analyzer"
                cell.topicIcon.image = UIImage(named: "bodyScan-icon")!
                cell.descriptionLabel.text = "Detection by artificial intelligence of a nevus' pathology"
                cell.quantityLabel.text = "GO!"
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 70.0
        switch indexPath.row {
        case 1:
            height = 100.0
        default:
            height = 210.0
        }
        
        return height
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataCollectionCell", for: indexPath) as! DataCollectionViewCell
        cell.bacgroundImage.image = self.backgroundImages[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.dataLabel.text = "\(todaySteps)"
            cell.descriptionLabel.text = "Steps"
        case 1:
            cell.dataLabel.text = "\(patient!.workoutRecords.last?.calories ?? 0)"
            cell.descriptionLabel.text = "Calories"
        case 2:
            cell.dataLabel.text = "Height"
            cell.descriptionLabel.text = "\(patient?.heightRecords.last?.height ?? 0.0) cm"
        default:
            cell.dataLabel.text = "Weight"
            cell.descriptionLabel.text = "\(patient?.weightRecords.last?.weight ?? 0.0) lb"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 6 {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "VisualRecognizerVC") {
                present(viewController, animated: true)
                return
            }
        } else if indexPath.row > 1 {
            optionPressed = indexPath.row
            performSegue(withIdentifier: "tableSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableSegue" {
            if let navigationController = segue.destination as? UINavigationController {
                if let viewController = navigationController.topViewController as? RecordViewController {
                    var title = ""
                    var color = UIColor()
                    var icon = UIImage()
                    switch optionPressed {
                    case 2:
                        let records = Array(patient!.workoutRecords)
                        viewController.myRecords = records as [AnyObject]
                        title = "Calories Burned"
                        color = #colorLiteral(red: 0.9723386168, green: 0.5278795958, blue: 0.4031898975, alpha: 1)
                        icon = UIImage(named: "burn-icon")!
                    case 3:
                        let records = Array(patient!.sleepRecords)
                        viewController.myRecords = records as [AnyObject]
                        title = "Sleeping Hours"
                        color = #colorLiteral(red: 0.2653386891, green: 0.2729498446, blue: 0.6093763709, alpha: 1)
                        icon = UIImage(named: "moon-icon")!
                    case 4:
                        let records = Array(patient!.sleepRecords)
                        viewController.myRecords = records as [AnyObject]
                        title = "Calories Consumed"
                        color = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                        icon = UIImage(named: "food-icon")!
                    default:
                        let records = Array(patient!.hearthRecords)
                        viewController.myRecords = records as [AnyObject]
                        title = "Hearth BPM"
                        color = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                        icon = UIImage(named: "hearth-icon")!
                    }
                    viewController.mainColor = color
                    viewController.mainIcon = icon
                    viewController.recordTitle = title
                }
            }
        }
    }
    
}