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
        return self.toString(format: .ISO8601)
    }
    
    func toIsoNSString() -> NSString {
        return self.toString(format: .ISO8601) as NSString
    }
    
    convenience init(isoString : String) {
        let stringWithTime = isoString + " 00:00"
        self.init(fromString: stringWithTime, format: .ISO8601)
    }
    
}