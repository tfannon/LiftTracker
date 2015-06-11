//
//  FirebaseTests.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/10/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import XCTest
import LiftTracker


class FirebaseTests: XCTestCase {
    
    var myRootRef = Firebase(url:"https://lifttracker2.firebaseio.com/tests")

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExercise() {
        
        var alan = ["full_name": "Alan Turing", "date_of_birth": "June 23, 1912"]
        myRootRef.childByAppendingPath("alan").setValue(alan)
    }
    
    
    
}