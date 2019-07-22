//
//  DatabaseService.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/17/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

let FIR_CHILD_PATIENTS = "patients"
let FIR_CHILD_DOCTORS = "doctors"
let FIR_CHILD_APPOINTMENTS = "appointments"
class DatabaseService {
    private static let _shared = DatabaseService()
    
    static var shared: DatabaseService {
        return _shared
    }
    
    var mainRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var patientsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_PATIENTS)
    }
    
    var doctorsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_DOCTORS)
    }
    
    var appointmentsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_APPOINTMENTS)
    }
    
    var mainStorageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://healthapp-f49f3.appspot.com")
    }
    
    var imageStorageRef: StorageReference {
        return mainStorageRef.child("images")
    }
    
    func create(appointment: Appointment) {
        let newAppointment: Dictionary<String, AnyObject> = [
            "patientUID": appointment.patientUid as AnyObject,
            "doctorUID": appointment.doctorUid as AnyObject,
            "startDate": appointment.startDate.iso8601 as AnyObject,
            "endDate": appointment.endDate.iso8601 as AnyObject,
            "notes": appointment.notes as AnyObject
        ]
        self.patientsRef.child(appointment.patientUid).child("appointments").child(appointment.id).setValue(appointment.id)
        self.doctorsRef.child(appointment.doctorUid).child("appointments").child(appointment.id).setValue(appointment.id)
        self.appointmentsRef.child(appointment.id).setValue(newAppointment)
    }
    
    func saveDoctor(doctor: Doctor) {
        let profile: Dictionary<String, AnyObject> = ["firstName": doctor.firstName as AnyObject, "lastName": doctor.lastName as AnyObject, "email": doctor.email as AnyObject, "address": doctor.direction  as AnyObject, "phone": doctor.phone as AnyObject, "specialty": doctor.specialty as AnyObject]
        self.doctorsRef.child(doctor.uid).setValue(profile)
    }
    
    func savePictureRef(uid: String, url: URL) {
        let doctorRef: Dictionary<String, AnyObject> = ["profilePictureURL": url.absoluteString as AnyObject]
        self.doctorsRef.child(uid).child("profilePicture").setValue(doctorRef)
    }
    
    func saveProfilePictureRef(doctorUID: String, url: URL) {
        let doctorRef: Dictionary<String, AnyObject> = ["profilePicture": url.absoluteString as AnyObject]
        self.doctorsRef.child(doctorUID).child("profileURL").setValue(doctorRef)
    }
    
    func addDoctor(doctorUID: String, patientUID: String) {
        self.patientsRef.child(patientUID).child("doctors").child(doctorUID).child("removed").setValue(false)
    }
    
    func addPatient(doctorUID: String, patientUID: String) {
        self.doctorsRef.child(doctorUID).child("patients").child(patientUID).child("removed").setValue(false)
        self.addDoctor(doctorUID: doctorUID, patientUID: patientUID)
    }
    
    func removePatientWith(uid: String, doctorUID: String) {
        self.doctorsRef.child(doctorUID).child("patients").child(uid).child("removed").setValue(true)
        self.patientsRef.child(uid).child("patients").child(doctorUID).child("removed").setValue(true)
    }
    
    func remove(appointmentUID: String, patientUID: String, doctorUID: String) {
        self.appointmentsRef.child(appointmentUID).removeValue()
        self.patientsRef.child(patientUID).child("appointments").child(appointmentUID).child("removed").setValue(true)
        self.doctorsRef.child(doctorUID).child("appointments").child(appointmentUID).child("removed").setValue(true)
    }
    
    func saveBasicInfoInFirebase(doctor: Doctor) {
        let firstName = doctor.firstName
        let lastName = doctor.lastName
        let email = doctor.email
        let address = doctor.direction
        let phone = doctor.phone
        let speciality = doctor.specialty
        
        let dictionary: [String: AnyObject] = [
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "email": email as AnyObject,
            "address": address as AnyObject,
            "phone": phone as AnyObject,
            "speciality": speciality as AnyObject
        ]
        
        self.doctorsRef.child("\(doctor.uid)").setValue(dictionary)
    }
}

