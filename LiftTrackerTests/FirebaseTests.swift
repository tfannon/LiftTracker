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
        let jsonURL = NSBundle.mainBundle().URLForResource("Bodypart", withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        do {
            let jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments) as! NSArray
            let bodypartsNode = myRootRef.childByAppendingPath("bodyparts2")
            for x in jsonArray {
                let d = x as! NSDictionary
                let name = d["name"] as! String
                let newNode = bodypartsNode.childByAppendingPath(name)
                newNode.setValue(x)
            }
        
        } catch let caught as NSError {
            print(caught)
        } catch {
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
                    print("key:\(child.key!)")
                }
//                if let d = result.value as? NSDictionary {
//                    println(d["2015-07-01"]!)
//                }
                done = true
            })
        })
        
        waitUntil(5) { done }
    }
    
    func testAllPrsForExercise() {
        var done = false
        let prs = myRootRef.childByAppendingPath("/exercises/benchpress/prs")
        let oneRepNode = prs.childByAppendingPath("1")
        oneRepNode.childByAppendingPath("2015-07-01").setValue(225)
        oneRepNode.childByAppendingPath("2015-07-05").setValue(250)
        oneRepNode.childByAppendingPath("2015-07-07").setValue(255)
        
        let fiveRepNode = prs.childByAppendingPath("5")
        fiveRepNode.childByAppendingPath("2015-07-02").setValue(185)
        fiveRepNode.childByAppendingPath("2015-07-04").setValue(187.5)
        fiveRepNode.childByAppendingPath("2015-07-06").setValue(190)
        
        let tenRepNode = prs.childByAppendingPath("10")
        tenRepNode.childByAppendingPath("2015-07-02").setValue(135)
        tenRepNode.childByAppendingPath("2015-07-04").setValue(137.5)
        tenRepNode.childByAppendingPath("2015-07-06").setValue(140)
        
        prs.observeSingleEventOfType(.Value, withBlock: { (result : FDataSnapshot!) in
            for x in result.children {
                print(x)
            }
            done = true
        })
        
        waitUntil(5) { done }
    }
    
    
    func test() {
        let node = myRootRef.childByAppendingPath("main")
        let dict = ["foo":"bar"]
        var done = false
        
        node.setValue(dict) { (result) in
            print(result)
            done = true
        }
        
        waitUntil(5) { done }
        
        XCTAssert(done, "Completion should be called")
    }
    
    func waitUntil(timeout: NSTimeInterval, predicate:(Void -> Bool)) {
        let timeoutTime = NSDate(timeIntervalSinceNow: timeout).timeIntervalSinceReferenceDate
        
        while (!predicate() && NSDate.timeIntervalSinceReferenceDate() < timeoutTime) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.25))
        }
    }
    
    func testImporter() {
        let importer = FirebaseImporter(root: myRootRef)
        importer.importSeedDataIfNeeded(true)
        let done = false

        waitUntil(5) { done }
        
    }
}