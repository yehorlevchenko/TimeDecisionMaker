//
//  AppointmentWorker.swift
//  TimeDecisionMaker
//
//  Created by Yehor Levchenko on 5/9/19.
//

import Foundation

class AppointmentWorker {
    private let calendar = Calendar.current
    private let formatter = DateFormatter()
    var keysToParse = ["SUMMARY", "STATUS", "DESCRIPTION", "UID", "DTSTART", "DTEND"]
    var appointments = [Appointment]()
    var newAppointment: Appointment?
    
    func parseAppointments(from file: String) {
        appointments.removeAll()
        if let path = Bundle.main.path(forResource: file, ofType: "ics") {
            do {
                let rawData = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let rawAppointments = rawData.matchString(regex: "(?:BEGIN:VEVENT)[\\n|\\r|\\r\\n]+((.*):(.*)[\\n|\\r|\\r\\n]+)+?(?:END:VEVENT)")
                
                if rawAppointments.isEmpty {
                    print("Unable to parse ICS")
                } else {
                    for rawAppointment in rawAppointments {
                        prepareAppointment(from: rawAppointment.first!)
                    }
                }
            } catch {
                print("Cannot get appointments from file \(file)")
            }
        }
    }
    
    private func prepareAppointment(from raw: String) {
        newAppointment = Appointment()
        let rawElements = raw.components(separatedBy: .newlines)
        for line in rawElements {
            if keysToParse.contains(where: line.contains) {
                let splittedLine = line.matchString(regex: "(.*):(.*)")
                let key = splittedLine.first![1]
                let value = splittedLine.first![2]
                switch key {
                case "SUMMARY": newAppointment?.summary = value
                case "STATUS": newAppointment?.eventStatus = (newAppointment?.statusFromString(status: value))!
                case "DESCRIPTION": newAppointment?.eventDescription = value
                case "UID": newAppointment?.UID = value
                case "DTSTART": newAppointment?.dateOfStart = newAppointment?.dateFromString(value: value, format: "yyyyMMdd'T'HHmmss'Z'")
                case "DTSTART;VALUE=DATE": newAppointment?.dateOfStart = newAppointment?.dateFromString(value: value+"T120000Z", format: "yyyyMMdd'T'HHmmss'Z'")
                case "DTEND": newAppointment?.dateOfEnd = newAppointment?.dateFromString(value: value, format: "yyyyMMdd'T'HHmmss'Z'")
                case "DTEND;VALUE=DATE": newAppointment?.dateOfEnd = newAppointment?.dateFromString(value: value+"T120000Z", format: "yyyyMMdd'T'HHmmss'Z'")
                default: print("Invalid key-value pair, somehow: \(key) - \(value)")
                }
            }
        }
        
        if (newAppointment?.validate())! {
            appointments.append(newAppointment!)
        } else {
            print("Invalid appointment")
        }
    }
    
    public func filterAppointmentsByMonth(_ month: Int, in filtered: [Int: Appointment]) -> [Int: Appointment] {
        var updatedDictionary = filtered
        for appointment in appointments {
            let dateComponents = calendar.dateComponents([.month, .day], from: appointment.dateOfStart)
            if let appointmentMonth = dateComponents.month, let appointmentDay = dateComponents.day {
                if month == appointmentMonth {
                    updatedDictionary[appointmentDay] = appointment
                }
            }
        }
        return updatedDictionary
    }
    
    public func filterAppointmentsByDay(day: Int, month: Int) -> [Appointment] {
        var result = [Appointment]()
        for appointment in appointments {
            let dateComponents = calendar.dateComponents([.month, .day, .hour], from: appointment.dateOfStart)
            if let appointmentMonth = dateComponents.month, let appointmentDay = dateComponents.day, let appointmentHour = dateComponents.hour {
                if day == appointmentDay && month == appointmentMonth {
                    result.append(appointment)
                }
            }
        }
        return result
    }
}
