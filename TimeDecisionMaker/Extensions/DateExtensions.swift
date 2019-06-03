//
//  DateExtensions.swift
//  TimeDecisionMaker
//
//  Created by Yehor Levchenko on 5/19/19.
//

import Foundation

extension Date {
    
    func getNumberOfDaysInMonth(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
    
    func getDayOfWeek(year: Int, month: Int, day: Int) -> Int? {
        let stringDate = "\(year)-\(month)-\(day)"
        let formatter  = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        guard let todayDate = formatter.date(from: stringDate) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate) - 2
        return weekDay
    }
}
