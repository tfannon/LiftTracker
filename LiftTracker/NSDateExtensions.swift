//
//  NSDateExtensions.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 7/20/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation

extension NSDate {
    func toIsoString() -> String {
        return (self.toString(format: .ISO8601) as NSString).substringToIndex(10)
    }
    
    func toShortString() -> String {
        return self.toString(dateStyle: .ShortStyle, timeStyle: .NoStyle, doesRelativeDateFormatting: false)
    }
    
    convenience init(isoString : String) {
        let stringWithTime = isoString + "T00:00:00-05:00"
        println("NSDate constructed with \(stringWithTime)")
        self.init(fromString: stringWithTime, format: .ISO8601)
    }
    
}