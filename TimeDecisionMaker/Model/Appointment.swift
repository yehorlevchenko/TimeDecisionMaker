//
//  Appointment.swift
//  TimeDecisionMaker
//
//  Created by Yehor Levchenko on 5/9/19.
//

import Foundation
import EventKit

class Appointment {
    
    public var UID: String
    public var summary: String
    public var eventDescription: String
    public var eventStatus: Status
    public var dateOfStart: Date!
    public var dateOfEnd: Date!
    
    init() {
        self.UID = ""
        self.summary = ""
        self.eventDescription = ""
        self.eventStatus = .UNSET
    }
    
    public func validate() -> Bool {
        return (UID != "" || summary != "" || eventDescription != "" || eventStatus != Status.UNSET || dateOfStart != nil || dateOfEnd != nil)
    }
    
    public func statusFromString(status: String) -> Status {
        switch status {
        case "CONFIRMED":
            return .CONFIRMED
        case "TENTATIVE":
            return .TENTATIVE
        case "CANCELLED":
            return .CANCELLED
        case "NONE":
            return .UNSET
        default:
            return .UNSET
        }
    }
    
    public func dateFromString(value: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from: value) {
            return date
        } else {
            return Date()
        }
    }
}

enum Status : String {
    
    case TENTATIVE = "TENTATIVE"
    case CONFIRMED = "CONFIRMED"
    case CANCELLED = "CANCELLED"
    case UNSET
    
    var description: String {
        return self.rawValue
    }
}
