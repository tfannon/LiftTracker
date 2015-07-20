//
//  AdminFunctions.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 7/19/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import XCTest
import LiftTracker

//these 'tests' are used to populate the database
class AdminFunctions: XCTestCase {
    var fbRoot = Firebase(url:"https://lifttracker2.firebaseio.com")
    var fbTestRoot = Firebase(url:"https://lifttracker2.firebaseio.com/test")
    
    func testAddExercises() {
        var importer = FirebaseImporter(root: fbRoot)
        importer.importSeedData()
        var done = false
        
        waitUntil(5) { done }
    }
    
    func waitUntil(timeout: NSTimeInterval, predicate:(Void -> Bool)) {
        var timeoutTime = NSDate(timeIntervalSinceNow: timeout).timeIntervalSinceReferenceDate
        
        while (!predicate() && NSDate.timeIntervalSinceReferenceDate() < timeoutTime) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.25))
        }
    }
    
    
}
