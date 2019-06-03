//
//  StringExtensions.swift
//  TimeDecisionMaker
//
//  Created by Yehor Levchenko on 5/19/19.
//

import Foundation

extension String {
    func matchString(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}
