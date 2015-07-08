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
    
    func testPR() {
        var done = false
        let oneRepNode = myRootRef.childByAppendingPath("/exercises/benchpress/prs/1")
        /* can do it this way by autoid
        var child = oneRepNode.childByAutoId()
        var pr = ["date":"2015-07-01", "weight":225]
        child.setValue(pr) { (result) in
        }
        child = oneRepNode.childByAutoId()
        pr = ["date":"2015-07-04", "weight":235]
        child.setValue(pr) { (result) in
        }
        child = oneRepNode.childByAutoId()
        pr = ["date":"2015-07-08", "weight":240]
        child.setValue(pr) { (result) in
            done = true
        }
        */
        
        oneRepNode.childByAppendingPath("2015-07-01").setValue(225)
        oneRepNode.childByAppendingPath("2015-07-05").setValue(250)
        //oneRepNode.childByAppendingPath("2015-07-10").setValue(240)
        oneRepNode.childByAppendingPath("2015-07-10").setValue(210, withCompletionBlock: { _ in
            //go fetch it
            //oneRepNode.queryOrderedByValue().observeEventType(.ChildAdded, withBlock: { (result) in
            oneRepNode.queryOrderedByValue().observeEventType(.Value, withBlock: { (result) in
                //println(result.value)
                for child in result.children {
                    println("key:\(child.key!)")
                }
//                if let d = result.value as? NSDictionary {
//                    println(d["2015-07-01"]!)
//                }
                done = true
            })
        })
        
        waitUntil(5) { done }
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