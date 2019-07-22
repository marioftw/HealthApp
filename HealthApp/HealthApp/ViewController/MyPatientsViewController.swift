//
//  MyPatientsViewController.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/8/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import UIKit
import RealmSwift
import FloatingPanel

class MyPatientsViewController: UIViewController {
    
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
        guard let uid = AuthService.shared.fireabseAuth.currentUser?.uid else { return }
        guard let localDoctor = realm?.object(ofType: Doctor.self, forPrimaryKey: uid) else { return }
        self.doctor = localDoctor
        tableView.allowsMultipleSelection = false
        self.navigationController?.navigationBar.setMinimal()
        createPanel()
        // Do any additional setup after loading the view.
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
                //viewController.patient = self.doctor
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
