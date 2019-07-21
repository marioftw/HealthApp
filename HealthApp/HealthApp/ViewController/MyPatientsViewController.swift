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
        // Do any additional setup after loading the view.
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
        cell.patientNameLabel.text = patients[indexPath.row].firstName
        cell.patientAgeLabel.text = "\(patients[indexPath.row].age)"
        cell.patientImageView.image = patients[indexPath.row].profilePicture
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPatientVC", sender: nil)
    }
}
