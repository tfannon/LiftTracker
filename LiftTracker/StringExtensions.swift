//
//  StringExtensions.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/19/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation

extension String {

    func trim() -> String {
       return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func toDate() -> NSDate {
        let date = NSDate(isoString: self)
        //println("converting \(self) to \(date)")
        return date
    }

}
