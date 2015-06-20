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
    
    var myRootRef = Firebase(url:"https://lifttracker2.firebaseio.com/test")

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testJson() {
        var error: NSError? = nil
        let jsonURL = NSBundle.mainBundle().URLForResource("Bodypart", withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        let jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSArray
        var bodypartsNode = myRootRef.childByAppendingPath("bodyparts2")
        for x in jsonArray {
            println(x)
            let d = x as! NSDictionary
            println(d)
            let name = d["name"] as! String
            var newNode = bodypartsNode.childByAppendingPath(name)
            newNode.setValue(x)
        }
    }
    
    func test() {
        var node = myRootRef.childByAppendingPath("main")
        var dict = ["foo":"bar"]
        var done = false
        
        node.setValue(dict) { (result) in
            println(result)
            done = true
        }
        
        waitUntil(5) { done }
        
        XCTAssert(done, "Completion should be called")
    }
    
    func waitUntil(timeout: NSTimeInterval, predicate:(Void -> Bool)) {
        var timeoutTime = NSDate(timeIntervalSinceNow: timeout).timeIntervalSinceReferenceDate
        
        while (!predicate() && NSDate.timeIntervalSinceReferenceDate() < timeoutTime) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.25))
        }
    }
    
    func testImporter() {
        var importer = FirebaseImporter(root: myRootRef)
        importer.importSeedDataIfNeeded(overwrite: true)
        var done = false

        waitUntil(5) { done }
        
    }
}