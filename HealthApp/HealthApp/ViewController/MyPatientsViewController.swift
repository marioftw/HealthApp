//
//  MyPatientsViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseStorage
import FloatingPanel

class MyPatientsViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    var patients: [Patient]?
    var doctor: Doctor?
    var selectedPatient: Patient!
    var isSelectionAllowed = false
    let realm = try? Realm()
    var fpc: FloatingPanelController!
    var QRVC: QRViewController!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = self.parent as? CreateAppointmentViewController {
            self.doctor = navigationController.doctor
        }
        tableView.allowsMultipleSelection = false
        self.navigationController?.navigationBar.setMinimal()
        NotificationCenter.default.addObserver(self, selector: #selector(getPatientsUIDS), name: Notification.Name("UpdatePatientsTable"), object: nil)
        getPatientsUIDS()
        setRefreshControl()
        createPanel()
        // Do any additional setup after loading the view.
    }
    
    func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.black
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching User Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(getPatientsUIDS), for: .valueChanged)
    }
    
    @IBAction func dondeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a Patient", message: "How do you want to add a new patient?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Show my DoctorID", style: .default, handler: { (action) in
            self.fpc.show(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Scan PatientID", style: .default, handler: { (action) in
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "QRAnalyzerVC") as? QRAnalyzerViewController {
                viewController.doctor = self.doctor
                self.present(viewController, animated: true)
                return
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func createPanel() {
        guard self.doctor != nil else { return }
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.show()
        
        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.cornerRadius = 30.0
        fpc.surfaceView.shadowHidden = true
        fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
        fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
        
        QRVC = storyboard?.instantiateViewController(withIdentifier: "QRViewController") as? QRViewController
        QRVC.fpc = self.fpc
        QRVC.doctorUID = self.doctor?.uid
        
        fpc.set(contentViewController: QRVC)
        fpc.addPanel(toParent: self, belowView: nil, animated: false)
        fpc.hide()
    }
    
    @objc func getPatientsUIDS() {
        guard let doctorUID = doctor?.uid else { return }
        var uids = [String]()
        DatabaseService.shared.doctorsRef.child(doctorUID).child("patients").observeSingleEvent(of: .value) { (snapshot) in
            if let patientsUID = snapshot.value as? Dictionary<String, AnyObject> {
                for patientUID in patientsUID {
                    if let removed = patientUID.value["removed"] as? Bool {
                        if removed {
                            DispatchQueue.main.async {
                                self.doctor?.removePatientWith(uid: patientUID.key)
                                self.tableView.reloadData()
                            }
                        } else {
                            uids.append(patientUID.key)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.downloadPatients(uids: uids)
            }
        }
    }
    
    func downloadPatients(uids: [String]) {
        for uid in uids {
            var patient: Patient?
            var patientFirstName = ""
            var patientLastName = ""
            var patientEmail = ""
            var patientBiologicalSex = ""
            var patientAge = 0
            var patientBloodType = ""
            var profileImageURL = ""
            let patientHearthRecords        = List<HearthRecord>()
            let patientHeightRecords        = List<Height>()
            let patientWeightRecords        = List<Weight>()
            let patientIngestedFoodsRecords = List<Food>()
            let patientWorkoutsRecords      = List<WorkoutRecord>()
            let patientSleepRecords         = List<SleepAnalisys>()
            DatabaseService.shared.patientsRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let patientDict = snapshot.value as? Dictionary<String, AnyObject> {
                    if let profile = patientDict["profile"] as? Dictionary<String, AnyObject> {
                        if let profilePicture = profile["profilePicture"] as? Dictionary<String, AnyObject> {
                            if let profileURL = profilePicture["profilePictureURL"] as? String {
                                profileImageURL = profileURL
                            }
                        }
                        
                        if let basicData = profile["basicData"] as? Dictionary<String, AnyObject> {
                            if let email = basicData["email"] as? String,
                                let firstName = basicData["firstName"] as? String,
                                let lastName = basicData["lastName"] as? String
                            {
                                patientFirstName = firstName
                                patientLastName = lastName
                                patientEmail = email
                            }
                        }
                        
                        if let healthData = profile["healthData"] as? Dictionary<String, AnyObject> {
                            if let age = healthData["age"] as? Int,
                                let biologicalSex = healthData["biologicalSex"] as? String,
                                let bloodType = healthData["bloodType"] as? String {
                                patientBiologicalSex = biologicalSex
                                patientAge = age
                                patientBloodType = bloodType
                            }
                        }
                    }
                    
                    if let sleepRecords = patientDict["sleepRecords"] as? Dictionary<String, AnyObject> {
                        for sleepRecord in sleepRecords {
                            if let record = sleepRecords[sleepRecord.key] as? Dictionary<String, AnyObject> {
                                if let startDate = record["startDate"] as? String,
                                    let endDate = record["endDate"] as? String {
                                    if let myStartDate = startDate.createDate,
                                        let myEndDate = endDate.createDate
                                    {
                                        DispatchQueue.main.async {
                                            if self.realm?.object(ofType: SleepAnalisys.self, forPrimaryKey: "Doctor\(myStartDate)") == nil {
                                                print("Agregando récrod: \(myStartDate.formattedDate)")
                                                patientSleepRecords.append(SleepAnalisys(startDate: myStartDate, endDate: myEndDate))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if let heightRecords = patientDict["heightRecords"] as? Dictionary<String, AnyObject> {
                        for heightRecord in heightRecords {
                            if let startDate = heightRecord.key.createDate,
                                let height = heightRecord.value as? Double
                            {
                                DispatchQueue.main.async {
                                    if self.realm?.object(ofType: Height.self, forPrimaryKey: "Doctor\(startDate)") == nil {
                                        patientHeightRecords.append(Height(height: height, startDate: startDate, endDate: Date()))
                                    }
                                }
                            }
                        }
                    }
                    
                    if let heartRecords = patientDict["hearthRecords"] as? Dictionary<String, AnyObject> {
                        for hearthRecord in heartRecords {
                            if let startDate = hearthRecord.key.createDate,
                                let bpm = hearthRecord.value as? Int
                            {
                                DispatchQueue.main.async {
                                    if self.realm?.object(ofType: HearthRecord.self, forPrimaryKey: "Doctor\(startDate.iso8601)") == nil {
                                        patientHearthRecords.append(HearthRecord(bpm: bpm, startDate: startDate, endDate: Date()))
                                    }
                                }
                            }
                        }
                    }
                    
                    if let weightRecords = patientDict["weightRecords"] as? Dictionary<String, AnyObject> {
                        for weightRecord in weightRecords {
                            if let startDate = weightRecord.key.createDate,
                                let weight = weightRecord.value as? Double
                            {
                                DispatchQueue.main.async {
                                    if self.realm?.object(ofType: Weight.self, forPrimaryKey: "Doctor\(startDate)") == nil {
                                        patientWeightRecords.append(Weight(weight: weight, startDate: startDate, endDate: Date()))
                                    }
                                }
                            }
                        }
                    }
                    
                    if let workoutsRecords = patientDict["workoutRecords"] as? Dictionary<String, AnyObject> {
                        for workoutRecord in workoutsRecords {
                            if let startDate = workoutRecord.key.createDate,
                                let calories = workoutRecord.value as? Double
                            {
                                DispatchQueue.main.async {
                                    if self.realm?.object(ofType: WorkoutRecord.self, forPrimaryKey: "Doctor\(startDate)") == nil {
                                        patientWorkoutsRecords.append(WorkoutRecord(startDate: startDate, endDate: Date(), caloriesBurned: calories))
                                    }
                                }
                            }
                        }
                    }
                    
                    if let ingestedFoods = patientDict["ingestedFoodRecords"] as? Dictionary<String, AnyObject> {
                        for ingestedFood in ingestedFoods {
                            if let food = ingestedFoods[ingestedFood.key] as? Dictionary<String, AnyObject> {
                                if let startDate = ingestedFood.key.createDate,
                                    let calories = food["calories"] as? Double,
                                    let name = food["name"] as? String
                                {
                                    DispatchQueue.main.async {
                                        if self.realm?.object(ofType: Food.self, forPrimaryKey: "Doctor\(startDate)") == nil {
                                            patientIngestedFoodsRecords.append(Food(kilocalories: calories, name: name, startDate: startDate, endDate: Date()))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if let myPatient = self.realm?.object(ofType: Patient.self, forPrimaryKey: uid) {
                            patient = myPatient
                            do {
                                try self.realm?.write {
                                    patient?.firstName = patientFirstName
                                    patient?.lastName = patientLastName
                                    patient?.email = patientEmail
                                    patient?.biologicalSex = patientBiologicalSex
                                    patient?.age = patientAge
                                    patient?.bloodType = patientBloodType
                                    
                                    patient?.hearthRecords.append(objectsIn: patientHearthRecords)
                                    patient?.heightRecords.append(objectsIn: patientHeightRecords)
                                    patient?.weightRecords.append(objectsIn: patientWeightRecords)
                                    patient?.sleepRecords.append(objectsIn: patientSleepRecords)
                                    patient?.workoutRecords.append(objectsIn: patientWorkoutsRecords)
                                    patient?.ingestedFoods.append(objectsIn: patientIngestedFoodsRecords)
                                }
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                        } else {
                            patient = Patient(uid: uid, age: patientAge, firstName: patientFirstName, lastName: patientLastName, bloodType: patientBloodType, bilogicalSex: patientBiologicalSex, email: patientEmail)
                            do {
                                try self.realm?.write {
                                    patient?.hearthRecords.append(objectsIn: patientHearthRecords)
                                    patient?.heightRecords.append(objectsIn: patientHeightRecords)
                                    patient?.weightRecords.append(objectsIn: patientWeightRecords)
                                    patient?.sleepRecords.append(objectsIn: patientSleepRecords)
                                    patient?.workoutRecords.append(objectsIn: patientWorkoutsRecords)
                                    patient?.ingestedFoods.append(objectsIn: patientIngestedFoodsRecords)
                                    self.doctor?.patients.append(patient!)
                                }
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        DispatchQueue.main.async {
                            self.downloadPatientProfieImage(imageURL: profileImageURL, patient: patient!)
                        }
                    }
                }
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func downloadPatientProfieImage(imageURL: String, patient: Patient) {
        if imageURL != "" {
            let httpRef = Storage.storage().reference(forURL: imageURL)
            httpRef.getData(maxSize: 15*1024*1024, completion: { (data, error) in
                if error != nil {
                    print("Error al descargar la imagen: \(String(describing: error?.localizedDescription))")
                } else {
                    do {
                        try self.realm?.write {
                            patient.dataProfilePicture = data
                        }
                    } catch {
                        print("No se pudo poner la imagen")
                    }
                    
                }
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPatientVC" {
            if let viewController = segue.destination as? PatientProfileViewController {
                viewController.patient = self.selectedPatient
            }
        }
    }
    
}

extension MyPatientsViewController: UITableViewDataSource, UITableViewDelegate, FloatingPanelControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctor?.patients.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell") as! PatientTableViewCell
        cell.allowsSelection = isSelectionAllowed
        cell.selectionStyle = .none
        cell.patientNameLabel.text = doctor?.patients[indexPath.row].firstName ?? ""
        cell.patientAgeLabel.text = "\(doctor?.patients[indexPath.row].age ?? 0)"
        cell.patientImageView.image = doctor?.patients[indexPath.row].profilePicture ?? UIImage(named: "profile-placeholder")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPatient = doctor?.patients[indexPath.row]
        
        if let parentViewController = self.parent as? CreateAppointmentViewController {
            parentViewController.doctor = self.doctor
            parentViewController.selectedPatient = self.selectedPatient
            return
        }
        
        performSegue(withIdentifier: "showPatientVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let patientToRemove = doctor?.patients[indexPath.row] else {
            return UISwipeActionsConfiguration(actions: [])
        }
        
        let action =  UIContextualAction(style: .destructive, title: "Remove", handler: { (action,view,completionHandler ) in
            DispatchQueue.main.async {
                self.doctor?.remove(patient: patientToRemove)
                self.tableView.deleteRows(at: [indexPath], with: .left)
            }
            completionHandler(true)
        })
        action.image = UIImage(named: "trash-circle")
        action.backgroundColor = #colorLiteral(red: 0.9243228436, green: 0.9181587696, blue: 0.9177718163, alpha: 1)
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [action])
        
        return swipeActionsConfiguration
    }
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return CustomLayout()
    }
    
    func floatingPanel(_ vc: FloatingPanelController, behaviorFor newCollection: UITraitCollection) -> FloatingPanelBehavior? {
        return CustomBehaivor()
    }
}

class CustomBehaivor: FloatingPanelBehavior {
    var velocityThreshold: CGFloat {
        return 15.0
    }
    
    func interactionAnimator(_ fpc: FloatingPanelController, to targetPosition: FloatingPanelPosition, with velocity: CGVector) -> UIViewPropertyAnimator {
        let timing = timeingCurve(to: targetPosition, with: velocity)
        return UIViewPropertyAnimator(duration: 0, timingParameters: timing)
    }
    
    private func timeingCurve(to: FloatingPanelPosition, with velocity: CGVector) -> UITimingCurveProvider {
        let damping = self.damping(with: velocity)
        return UISpringTimingParameters(dampingRatio: damping,
                                        frequencyResponse: 0.4,
                                        initialVelocity: velocity)
    }
    
    private func damping(with velocity: CGVector) -> CGFloat {
        switch velocity.dy {
        case ...(-velocityThreshold):
            return 0.7
        case velocityThreshold...:
            return 0.7
        default:
            return 1.0
        }
    }
}

class CustomLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.half, .hidden, .full, .tip]
    }
    
    var topInteractionBuffer: CGFloat { return 0.0 }
    var bottomInteractionBuffer: CGFloat { return 0.0 }
    
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 56.0
        case .half: return 350.0
        case .tip: return 85.0 + 44.0 // Visible + ToolView
        case .hidden: return nil
        }
    }
    
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}
