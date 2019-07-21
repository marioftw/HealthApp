//
//  Patient.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/9/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import Foundation
import RealmSwift

class Patient: Object {
    @objc private(set) dynamic var _uid: String = ""
    @objc private(set) dynamic var _age: Int = 0
    @objc private(set) dynamic var _firstName: String = ""
    @objc private(set) dynamic var _lastName: String = ""
    @objc private(set) dynamic var _bloodType: String = ""
    @objc private(set) dynamic var _biologialSex: String = ""
    @objc private(set) dynamic var _email: String = ""
    @objc private(set) dynamic var _profilePicture: Data?
    var heightRecords = List<Height>()
    var weightRecords = List<Weight>()
    var sleepRecords = List<SleepAnalisys>()
    var workoutRecords = List<WorkoutRecord>()
    var hearthRecords = List<HearthRecord>()
    var ingestedFoods = List<Food>()
    
    override static func primaryKey() -> String? {
        return "_uid"
    }
    
    convenience init(uid: String, age: Int, firstName: String, lastName: String, bloodType: String, bilogicalSex: String, email: String) {
        self.init()
        self._uid = uid
        self._age = age
        self._firstName = firstName
        self._lastName = lastName
        self._bloodType = bloodType
        self._biologialSex = biologicalSex
        self._email = email
    }
    
    var uid: String {
        set {
            _uid = newValue
        }
        get {
            return _uid
        }
    }

    var email: String {
        set {
            _email = newValue
        }
        get {
            return _email
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
    
    var profilePicture: UIImage? {
        guard let profileImage = _profilePicture else { return nil }
        if let image = UIImage(data: profileImage) {
            return image
        }
        return nil
    }
    
    var dataProfilePicture: Data? {
        set {
            _profilePicture = newValue
        }
        get {
            return _profilePicture
        }
    }
    
    var lastName: String {
        set {
            _lastName = newValue
        }
        get {
            return _lastName
        }
    }
    
    var bloodType: String {
        set {
            _bloodType = newValue
        }
        get {
            return _bloodType
        }
    }
    
    var age: Int {
        set {
            _age = newValue
        }
        get {
            return _age
        }
    }
    var biologicalSex: String {
        set{
            _biologialSex = newValue
        }
        get {
            return _biologialSex
        }
    }
    
}
