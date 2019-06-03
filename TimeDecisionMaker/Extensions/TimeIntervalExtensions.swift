//
//  TimeIntervalExtensions.swift
//  TimeDecisionMaker
//
//  Created by Yehor Levchenko on 6/1/19.
//

import Foundation

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = Int(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        
    }
}
