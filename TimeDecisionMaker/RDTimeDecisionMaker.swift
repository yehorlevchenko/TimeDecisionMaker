//
//  RDTimeDecisionMaker.swift
//  TimeDecisionMaker
//
//  Created by Mikhail on 4/24/19.
//

import Foundation

class RDTimeDecisionMaker: NSObject {
    /// Main method to perform date interval calculation
    ///
    /// - Parameters:
    ///   - organizerICSPath: path to personA file with events
    ///   - attendeeICSPath: path to personB file with events
    ///   - duration: desired duration of appointment
    /// - Returns: array of available time slots, empty array if none found
    func suggestAppointments(organizerICS:String,
                             attendeeICS:String,
                             duration:TimeInterval) -> [DateInterval] {
        let appointmentWorker = AppointmentWorker()
        appointmentWorker.parseAppointments(from: organizerICS)
        let organizerEvents = appointmentWorker.appointments
        appointmentWorker.parseAppointments(from: attendeeICS)
        let attendeeEvents = appointmentWorker.appointments
        
        var organizerIntervals = prepareIntervals(from: organizerEvents)
        organizerIntervals = findFreeSlots(with: organizerIntervals)
        var attendeeIntervals = prepareIntervals(from: attendeeEvents)
        attendeeIntervals = findFreeSlots(with: attendeeIntervals)
        
        let suggestedSlots = findAppointmentSlots(organizerEvents: organizerIntervals, attendeeEvents: attendeeIntervals, duration: duration)
        print(suggestedSlots.first?.duration)
        return suggestedSlots
    }
    
    func prepareIntervals(from events: [Appointment]) -> [DateInterval] {
        var intervals = [DateInterval]()
        for event in events {
            let eventInterval = DateInterval(start: event.dateOfStart, end: event.dateOfEnd)
            if eventInterval.end > Date() {
                intervals.append(eventInterval)
            }
        }
        
        return intervals
    }
    
    func findFreeSlots(with occupiedSlots: [DateInterval]) -> [DateInterval] {
        
        var freeSlots = [DateInterval]()
        guard occupiedSlots.count > 1 else {
            if occupiedSlots.first?.end != nil && occupiedSlots.first?.start != nil{
                if occupiedSlots.first!.end < Date() {
                    return [DateInterval.init(start: Date(), duration: 604800)]
                } else if occupiedSlots.first!.start > Date() {
                    return [DateInterval(start: Date(), end: occupiedSlots.first!.start), DateInterval(start: occupiedSlots.first!.end, duration: 604800)]
                }
            } else {
                return [DateInterval.init(start: Date(), duration: 604800)]
            }
            return []
        }
        
        for i in 0..<occupiedSlots.count {
            if i < occupiedSlots.count-1 && occupiedSlots[i].start != occupiedSlots[i+1].start && occupiedSlots[i].end != occupiedSlots[i+1].end {
                let newSlot = DateInterval.init(start: occupiedSlots[i].end, end: occupiedSlots[i+1].start)
                freeSlots.append(newSlot)
            }
        }
        
        freeSlots.append(DateInterval(start: Date(), end: occupiedSlots.min()!.start))
        freeSlots.append(DateInterval(start: occupiedSlots.max()!.end, duration: 604800))
        freeSlots.sort()
        return freeSlots
    }
    
    func findAppointmentSlots(organizerEvents: [DateInterval], attendeeEvents: [DateInterval], duration: TimeInterval) -> [DateInterval] {
        var optimalTimeIntervals = [DateInterval]()
        for orgEvent in organizerEvents {
            for attEvent in attendeeEvents {
                if orgEvent.intersects(attEvent) {
                    if orgEvent.intersection(with: attEvent)!.duration > duration {
                        optimalTimeIntervals.append(orgEvent.intersection(with: attEvent)!)
                    }
                }
            }
        }
        return optimalTimeIntervals
    }
}
