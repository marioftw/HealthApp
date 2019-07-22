//
//  HealthKitService.swift
//  HealthApp
//
//  Created by Moisés Córdova on 7/9/19.
//  Copyright © 2019 Moisés Córdova. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitService {
    private static let _shared = HealthKitService()
    static var shared: HealthKitService {
        return _shared
    }
    
    func getWholeDate(date: Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate, endDate)
    }
    
    func getFormated(measure: Double, on: MeasurementUnit) -> String {
        var formatedMeasure = ""
        var convertedUnit = 0.0
        switch on {
        case .feet:
            convertedUnit = measure * 0.032808
            formatedMeasure = "\(convertedUnit.rounded()) ft"
            break
        case .kilogram:
            convertedUnit = measure / 1000
            formatedMeasure = "\(convertedUnit.rounded()) kg"
        case .meter:
            if measure < 100 {
                formatedMeasure = "\(measure) Mt"
            } else {
                convertedUnit = measure / 100
                formatedMeasure = "\(convertedUnit) Mt"
            }
        case .pound:
            convertedUnit = measure / 453.592
            formatedMeasure = "\(convertedUnit.rounded()) lb"
        }
        return formatedMeasure
    }
    
    
    func getFormated(sample: HKQuantitySample, forValue: HealthValue) -> AnyObject {
        var toFormat = "\(sample.quantity)"
        switch forValue {
        case .hearth:
            toFormat = toFormat.replacingOccurrences(of: " count/min", with: "")
            if let formated = Int(toFormat) {
                return formated as AnyObject
            } else {
                return 0.0 as AnyObject
            }
        case .height:
            toFormat = toFormat.replacingOccurrences(of: " cm", with: "")
            toFormat = toFormat.replacingOccurrences(of: " m", with: "")
            if let formated = Double(toFormat) {
                return formated as AnyObject
            } else {
                return 0.0 as AnyObject
            }
        case .weight:
            if toFormat.contains("lb") {
                toFormat = toFormat.replacingOccurrences(of: " lb", with: "")
                if let formated = Double(toFormat) {
                    return formated as AnyObject
                } else {
                    return 0.0 as AnyObject
                }
            } else if toFormat.contains("g") {
                toFormat = toFormat.replacingOccurrences(of: " g", with: "")
                if let formated = Double(toFormat) {
                    return formated as AnyObject
                } else {
                    return 0.0 as AnyObject
                }
            } else {
                if (Double(toFormat) != nil) {
                    return toFormat as AnyObject
                } else {
                    return 0.0 as AnyObject
                }
            }
            
        }
    }
    
}
