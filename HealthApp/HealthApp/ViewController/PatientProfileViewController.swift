//
//  PatientProfileViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class PatientProfileViewController: UIViewController {
    
    var patient: Patient!
    var optionPressed = -1
    
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
        if self.navigationController?.popViewController(animated: true) == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            if let viewController = navigationController.topViewController as? RecordViewController {
                var title = ""
                var color = UIColor()
                var icon = UIImage()
                viewController.patientName = patient.firstName
                switch optionPressed {
                case 1:
                    let records = Array(patient!.hearthRecords)
                    viewController.myRecords = records as [AnyObject]
                    title = "Hearth Records"
                    color = #colorLiteral(red: 0.9995251298, green: 0.7069824338, blue: 0.6729323268, alpha: 1)
                    icon = UIImage(named: "hearth-icon")!
                case 2:
                    let records = Array(patient!.weightRecords)
                    viewController.myRecords = records as [AnyObject]
                    title = "Weight Records"
                    color = #colorLiteral(red: 0.3993943036, green: 0.5611467361, blue: 0.5224861503, alpha: 1)
                    icon = UIImage(named: "weight-icon")!
                case 3:
                    let records = Array(patient!.heightRecords)
                    viewController.myRecords = records as [AnyObject]
                    color = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
                    icon = UIImage(named: "height-icon")!
                case 4:
                    let records = Array(patient!.sleepRecords)
                    viewController.myRecords = records as [AnyObject]
                    title = "Sleeping Hours"
                    color = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
                    icon = UIImage(named: "moon-icon")!
                case 5:
                    let records = Array(patient!.ingestedFoods)
                    viewController.myRecords = records as [AnyObject]
                    title = "Calories Consumed"
                    color = #colorLiteral(red: 0.14901492, green: 0.3072064519, blue: 0.4399905205, alpha: 1)
                    icon = UIImage(named: "food-icon")!
                default:
                    let records = Array(patient!.workoutRecords)
                    viewController.myRecords = records as [AnyObject]
                    title = "Workouts"
                    color = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                    icon = UIImage(named: "workout-icon")!
                }
                viewController.mainColor = color
                viewController.mainIcon = icon
                viewController.recordTitle = title
            }
        }
    }
    
}

extension PatientProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! SecondaryTableViewCell
            cell.patientNameLabel.text = "\(patient.firstName) \(patient.lastName)"
            cell.patientImageView.image = patient.profilePicture ?? UIImage(named: "profile-placeholder")
            
            cell.firstDetailLabel.text = "Age"
            cell.firstContentLabel.text = "\(patient.age) y/o"
            cell.secondDetailLabel.text = "Height"
            cell.secondContentLabel.text = HealthKitService.shared.getFormated(measure: patient.heightRecords.last?.height ?? 0.0, on: .meter)
            cell.thirdDetailLabel.text = "Weight"
            cell.thirdContentLabel.text = HealthKitService.shared.getFormated(measure: patient.weightRecords.last?.weight ?? 0.0, on: .kilogram)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
        
        switch indexPath.row {
        case 1:
            cell.titleLabel.text = "Hearth"
            cell.statusCardLabel.text = "Healthy"
            
            cell.firstItemLabel.text = "\(patient.hearthRecords.first?.bpm ?? 0) BPM"
            cell.firstDetailLabel.text = "First"
            
            cell.secondItemLabel.text = patient.hearthRecords.last?.startDate.monthAndDayString
            cell.secondDetailLabel.text = "Date"
            
            cell.thirdItemLabel.text = "\(patient.hearthRecords.last?.bpm ?? 0) BPM"
            cell.thirdDetailLabel.text = "Last"
            
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.5908090472, green: 0.9698002934, blue: 0.7920762897, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.9995251298, green: 0.7069824338, blue: 0.6729323268, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.9485823512, green: 0.7537450194, blue: 0.7276101708, alpha: 1)
        case 2:
            cell.titleLabel.text = "Weight"
            cell.statusCardLabel.text = "Healthy"
            
            cell.firstItemLabel.text = "\(HealthKitService.shared.getFormated(measure: patient.weightRecords.first?.weight ?? 0.0, on: .kilogram))"
            cell.firstDetailLabel.text = "First"
            
            cell.secondItemLabel.text = patient.sleepRecords.first?.startDate.monthAndDayString
            cell.secondDetailLabel.text = "Date"
            
            cell.thirdItemLabel.text = "\(HealthKitService.shared.getFormated(measure: patient.weightRecords.last?.weight ?? 0.0, on: .kilogram))"
            cell.thirdDetailLabel.text = "Last"
            
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.5908090472, green: 0.9698002934, blue: 0.7920762897, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.3993943036, green: 0.5611467361, blue: 0.5224861503, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.4834083319, green: 0.6784313725, blue: 0.6100088954, alpha: 1)
        case 3:
            cell.titleLabel.text = "Height"
            cell.cardInfo.isHidden = true
            cell.firstItemLabel.text = "\(HealthKitService.shared.getFormated(measure: patient.heightRecords.first?.height ?? 0.0, on: .meter))"
            cell.firstDetailLabel.text = "First"
            
            cell.secondItemLabel.text = patient.sleepRecords.first?.startDate.monthAndDayString
            cell.secondDetailLabel.text = "Date"
            
            cell.thirdItemLabel.text = "\(HealthKitService.shared.getFormated(measure: patient.heightRecords.first?.height ?? 0.0, on: .meter))"
            cell.thirdDetailLabel.text = "Last"
            cell.cardView.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.339291418, alpha: 1)
        case 4:
            cell.titleLabel.text = "Sleep"
            cell.statusCardLabel.text = "Wrong"
            
            cell.firstItemLabel.text = (patient.sleepRecords.first?.hoursSleeping ?? "0")
            cell.firstDetailLabel.text = "First"
            
            cell.secondItemLabel.text = patient.sleepRecords.first?.startDate.monthAndDayString
            cell.secondDetailLabel.text = "Date"
            
            cell.thirdItemLabel.text = (patient.sleepRecords.last?.hoursSleeping ?? "0")
            cell.thirdDetailLabel.text = "Last"
            
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.5, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case 5:
            cell.titleLabel.text = "Alimentation"
            cell.statusCardLabel.text = "Healthy"
            
            cell.firstItemLabel.text = "\(patient.ingestedFoods.first?.kilocalories ?? 0.0)"
            cell.firstDetailLabel.text = "First"
            
            cell.secondItemLabel.text = patient.sleepRecords.first?.startDate.monthAndDayString
            cell.secondDetailLabel.text = "Date"
            
            cell.thirdItemLabel.text = "\(patient.ingestedFoods.first?.kilocalories ?? 0.0)"
            cell.thirdDetailLabel.text = "Last"
            
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.5908090472, green: 0.9698002934, blue: 0.7920762897, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.14901492, green: 0.3072064519, blue: 0.4399905205, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.14901492, green: 0.3440370624, blue: 0.3986850792, alpha: 1)
        default:
            cell.titleLabel.text = "Exercise"
            cell.statusCardLabel.text = "Lower"
            
            cell.firstItemLabel.text = "\(patient.workoutRecords.first?.calories ?? 0.0)"
            cell.firstDetailLabel.text = "First"
            
            cell.secondItemLabel.text = patient.workoutRecords.first?.startDate.monthAndDayString
            cell.secondDetailLabel.text = "Date"
            
            cell.thirdItemLabel.text = "\(patient.workoutRecords.last?.calories ?? 0.0)"
            cell.thirdDetailLabel.text = "Last"
            
            cell.statusCardLabel.textColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            cell.cardView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.cardInfo.backgroundColor = #colorLiteral(red: 0.3150302839, green: 0.5, blue: 0.3266408257, alpha: 1)
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        optionPressed = indexPath.row
        performSegue(withIdentifier: "showRecordsNC", sender: nil)
    }
}
