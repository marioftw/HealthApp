//
//  MyPatientsViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit

class MyPatientsViewController: UIViewController {
    
    var patients: [Patient] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setMinimal()
        self.patients = getPatients(number: 10)
        // Do any additional setup after loading the view.
    }
    
    func getPatients(number: Int) -> [Patient] {
        var myPatients = [Patient]()
        for _ in 0..<number {
            let patient = Patient(name: "Jeff Moon", age: 25, gender: "Male", profilePicture: #imageLiteral(resourceName: "male1"))
            myPatients.append(patient)
        }
        return myPatients
    }
    
    @IBAction func dondeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MyPatientsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell") as! PatientTableViewCell
        cell.patientNameLabel.text = patients[indexPath.row].name
        cell.patientAgeLabel.text = "\(patients[indexPath.row].age)"
        cell.patientImageView.image = patients[indexPath.row].profilePicture
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPatientVC", sender: nil)
    }
}

class Patient {
    var name: String = ""
    var age: Int = 0
    var gender: String = ""
    var profilePicture: UIImage!
    
    init(name: String, age: Int, gender: String, profilePicture: UIImage) {
        self.name = name
        self.age = age
        self.gender = gender
        self.profilePicture = profilePicture
    }
}
