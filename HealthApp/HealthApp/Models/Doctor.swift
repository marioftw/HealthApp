//
//  Doctor.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/9/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Doctor: Object {
    @objc private(set) dynamic var _firstName: String = ""
    @objc private(set) dynamic var _lastName: String = ""
    @objc private(set) dynamic var _direction: String = ""
    @objc private(set) dynamic var _email: String = ""
    @objc private(set) dynamic var _phone: String = ""
    @objc private(set) dynamic var _uid: String = ""
    @objc private(set) dynamic var _specialty: String = ""
    @objc private(set) dynamic var _profileImage: Data?
    var patients = List<Patient>()
    var appointments = List<Appointment>()
    
    override static func primaryKey() -> String? {
        return "_uid"
    }
    
    convenience init(uid: String) {
        self.init()
        self._firstName = ""
        self._lastName = ""
        self._direction = ""
        self._email = ""
        self._phone = ""
        self._uid = uid
        self._specialty = ""
    }
    
    var uid: String {
        set {
            _uid = newValue
        }
        get {
            return _uid
        }
    }
    
    var direction: String {
        set {
            _direction = newValue
        }
        get {
          return _direction
        }
    }
    var email:  String {
        set {
            _email = newValue
        }
        get {
          return _email
        }
    }
    var phone: String {
        set {
            _phone = newValue
        }
        get {
            return _phone
        }
    }
    
    var specialty: String {
        set {
            _specialty = newValue
        }
        get {
            return _specialty
        }
    }
    
    var firstName: String {
        set {
            _firstName = newValue
        }
        get {
            return _firstName
        }
    }
    
    var lastName: String {
        set {
            _lastName = newValue
        }
        get {
            _lastName
        }
    }
    
    var profilePicture: UIImage? {
        guard let profileData = _profileImage else { return nil }
        if let profileImage = UIImage(data: profileData) {
            return profileImage
        }
        return nil
    }
    
    var dataProfileImage: Data? {
        set {
            _profileImage = newValue
        }
        get {
            return _profileImage
        }
    }
    
    func remove(patient: Patient) {
        DatabaseService.shared.removePatientWith(uid: patient.uid, doctorUID: self.uid)
        do {
            try realm?.write {
                realm?.delete(patient)
            }
        } catch {
            print("Error deleting: \(error.localizedDescription)")
        }
    }
    
    func removePatientWith(uid: String) {
        if let localPatient = self.realm?.object(ofType: Patient.self, forPrimaryKey: uid) {
            self.remove(patient: localPatient)
        }
    }
}
