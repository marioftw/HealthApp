//
//  ViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseStorage

class ViewController: UIViewController {
    private let refreshControl = UIRefreshControl()
    var collectionView: UICollectionView!
    let realm = try? Realm()
    var doctor: Doctor?
    var todayPatients = [Patient]()
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setRefreshControl()
        initMethods()
    }
    
    @objc func initMethods() {
        setDoctor()
        checkCloudInformation()
        getPatientsUIDS()
        checkInCloudAppointments()
    }
    
    func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching User Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(initMethods), for: .valueChanged)
    }
    
    @objc func setDoctor() {
        if let myDoctor = realm?.objects(Doctor.self).first {
            self.doctor = myDoctor
        } else {
            if let uid = AuthService.shared.fireabseAuth.currentUser?.uid {
                self.doctor = Doctor(uid: uid)
                do {
                    try realm?.write {
                        realm?.add(self.doctor!)
                    }
                } catch {
                    print("Error Saving user: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func checkCloudInformation() {
        if let doctorUID = AuthService.shared.fireabseAuth.currentUser?.uid {
            DatabaseService.shared.doctorsRef.child(doctorUID).observeSingleEvent(of: .value) { (snapshot) in
                if let doctorDict = snapshot.value as? Dictionary<String, AnyObject> {
                    DispatchQueue.main.async {
                        self.checkChanges(doctorDict: doctorDict)
                        self.downloadProfileImage(doctorDict: doctorDict)
                    }
                }
            }
        }
    }
    
    func downloadProfileImage(doctorDict: Dictionary<String, AnyObject>) {
        if let profilePictureURL = doctorDict["profilePicture"] as? Dictionary<String, AnyObject> {
            if let imageURL = profilePictureURL["profilePictureURL"] as? String {
                let httpRef = Storage.storage().reference(forURL: imageURL)
                httpRef.getData(maxSize: 15*1024*1024, completion: { (data, error) in
                    if error != nil {
                        print("Error al descargar la imagen: \(String(describing: error?.localizedDescription))")
                    } else {
                        do {
                            try self.realm?.write {
                                self.doctor?.dataProfileImage = data
                            }
                        } catch {
                            print("No se pudo poner la imagen")
                        }
                    }
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    func checkChanges(doctorDict: Dictionary<String, AnyObject>) {
        var hasDoctor = true
        guard let uid = AuthService.shared.fireabseAuth.currentUser?.uid else { return }
        if doctor == nil {
            doctor = Doctor(uid: uid)
            hasDoctor = false
        }
        
        if let firstName = doctorDict["firstName"] as? String,
            let lastName = doctorDict["lastName"] as? String,
            let email = doctorDict["email"] as? String,
            let specialty = doctorDict["specialty"] as? String,
            let phone = doctorDict["phone"] as? String,
            let address = doctorDict["address"] as? String
        {
            do {
                try realm?.write {
                    if doctor?.firstName != firstName { doctor?.firstName = firstName }
                    if doctor?.lastName  != lastName  { doctor?.lastName = lastName   }
                    if doctor?.email     != email     { doctor?.email = email         }
                    if doctor?.specialty != specialty { doctor?.specialty = specialty }
                    if doctor?.phone     != phone     { doctor?.phone = phone         }
                    if doctor?.direction != address   { doctor?.direction = address   }
                }
            } catch {
                print("Error writting: \(error.localizedDescription)")
            }
        }
        
        if !hasDoctor {
            do {
                try realm?.write {
                    realm?.add(doctor!.self)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        self.tableView.reloadData()
    }
    
    func getPatientsUIDS() {
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
    
    func getAppointmentsFor(date: Date) -> [Appointment] {
        //let events = doctor?.appointments.filter({ return $0.startDate.shortDate == date.shortDate })
        //return events?.sorted(by: { $0.startDate < $1.startDate }) ?? []
        return doctor?.appointments.sorted(by: { $0.startDate < $1.startDate }) ?? []
    }
    
    @objc func checkInCloudAppointments() {
        var uids = [String]()
        guard let doctorUID = doctor?.uid else { return }
        DatabaseService.shared.doctorsRef.child(doctorUID).child("appointments").observeSingleEvent(of: .value) { (snapshot) in
            if let appointmentsUID = snapshot.value as? Dictionary<String, AnyObject> {
                for appointmentUID in appointmentsUID {
                    if let removed = appointmentUID.value["removed"] as? Bool {
                        if removed {
                            DispatchQueue.main.async {
                                self.doctor?.removeAppoinmentWith(uid: appointmentUID.key)
                                self.tableView.reloadData()
                            }
                        } else {
                            uids.append(appointmentUID.key)
                        }
                    }
                    
                }
            }
            
            DispatchQueue.main.async {
                self.downloadAppointments(uids: uids)
            }
        }
    }
    
    func downloadAppointments(uids: [String]) {
        for uid in uids {
            DatabaseService.shared.appointmentsRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let appointmentDict = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    if let patientUID = appointmentDict["patientUID"] as? String,
                        let startDate = appointmentDict["startDate"] as? String,
                        let endDate = appointmentDict["endDate"] as? String
                    {
                        if let myStartDate = startDate.createDate,
                            let myEndDate = endDate.createDate {
                            let notes = appointmentDict["notes"] as? String
                            DispatchQueue.main.async {
                                print(uid)
                                if self.realm?.object(ofType: Appointment.self, forPrimaryKey: uid) == nil {
                                   let appointment = Appointment(startDate: myStartDate, endDate: myEndDate, doctorUid: self.doctor!.uid, patientUid: patientUID, notes: notes)
                                    do {
                                        try self.realm?.write {
                                            self.doctor?.appointments.append(appointment)
                                        }
                                    } catch {
                                        print("Error writting locally: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        getPatientsWith(appointments: getAppointmentsFor(date: Date()))
    }
    
    func getPatientsWith(appointments: [Appointment]) {
        for appointment in appointments {
            guard let myPatient = realm?.object(ofType: Patient.self, forPrimaryKey: appointment.patientUid) else { return }
            if !todayPatients.contains(myPatient) {
                todayPatients.append(myPatient)
            }
        }
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func seeAllButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showPatientNC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController else { return }
    
        if segue.identifier == "showMyPatientsNC" {
                if let viewController = navigationController.topViewController as? MyPatientsViewController {
                    viewController.patients = Array<Patient>(self.doctor?.patients ?? List<Patient>())
                    viewController.doctor = self.doctor
                }
        } else if segue.identifier == "showPatientNC" {
            if let viewController = navigationController.topViewController as? PatientProfileViewController {
                viewController.patient = self.todayPatients.first
            }
        } else if segue.identifier == "showEditProfileNC" {
            if let navigationController = segue.destination as? UINavigationController {
                if let viewController = navigationController.topViewController as? EditProfileViewController {
                    viewController.doctor = self.doctor
                }
            }
        }
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainTableViewCell
            cell.nameLabel.text = "Dr. \(doctor?.lastName ?? "")"
            cell.patientsQuantityLabel.text = "You've got \(todayPatients.count) patients today"
            self.collectionView = cell.patientsCollectionView
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecondaryCell", for: indexPath) as! SecondaryTableViewCell
            cell.titleLabel.text = "Upcoming Patient"
            cell.patientNameLabel.text = todayPatients.first?.firstName
            cell.patientImageView.image = todayPatients.first?.profilePicture
            
            cell.firstDetailLabel.text = "Age"
            cell.firstContentLabel.text = "\(todayPatients.first?.age ?? 0) y/o"
            cell.secondDetailLabel.text = "Height"
            cell.secondContentLabel.text = HealthKitService.shared.getFormated(measure: todayPatients.first?.heightRecords.last?.height ?? 0.0, on: .meter)
            cell.thirdDetailLabel.text = "Weight"
            cell.thirdContentLabel.text = HealthKitService.shared.getFormated(measure: todayPatients.first?.weightRecords.last?.weight ?? 0.0, on: .kilogram)
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicBigTableViewCell
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9994794726, green: 0.9222456217, blue: 0.8273747563, alpha: 1)
            cell.titleLabel.textColor = #colorLiteral(red: 0.14901492, green: 0.3072064519, blue: 0.4399905205, alpha: 1)
            cell.subtitleLabel.textColor = #colorLiteral(red: 0.1918424666, green: 0.3328226805, blue: 0.4559432268, alpha: 1)
            cell.titleLabel.text = "My Patients"
            cell.subtitleLabel.text = "Look in a list with all your patients"
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicBigTableViewCell
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9723386168, green: 0.5278795958, blue: 0.4031898975, alpha: 1)
            cell.titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.titleLabel.text = "My Profile Info"
            cell.subtitleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.subtitleLabel.text = "Change your basic information"
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicBigTableViewCell
            cell.contentView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.5478317863, blue: 0.869705798, alpha: 1)
            cell.titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.titleLabel.text = "My Calendar"
            cell.subtitleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.subtitleLabel.text = "Check all your appointments"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicBigTableViewCell
            cell.contentView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            cell.titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.titleLabel.text = "Nevus Analyzer"
            cell.subtitleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.subtitleLabel.text = "Nevu's phatology scanner"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            performSegue(withIdentifier: "showMyPatientsNC", sender: nil)
            return
        }
        
        if indexPath.row == 3 {
            performSegue(withIdentifier: "showEditProfileNC", sender: nil)
            return
        }
        
        if indexPath.row == 4 {
            if let navigationController = storyboard?.instantiateViewController(withIdentifier: "calendarNV") as? UINavigationController {
                if let viewController = navigationController.topViewController as? CalendarViewController {
                    viewController.doctor = self.doctor
                    navigationController.modalPresentationStyle = .fullScreen
                    present(navigationController, animated: true)
                    return
                }
            }
        }
        
        if indexPath.row == 5 {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "VisualRecognizerVC") {
                present(viewController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 2 {
            return 450.0
        }
        
        return 200.0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todayPatients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientCell", for: indexPath) as! PatientCollectionViewCell
        cell.patientName.text = todayPatients[indexPath.row].firstName
        cell.patientImageView.image = todayPatients[indexPath.row].profilePicture
        
        return cell
    }
    
    
}
