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
    
    var fbTestRoot = Firebase(url:"https://lifttracker2.firebaseio.com/test")
    var fbTestUser : Firebase { get { return fbTestRoot.childByAppendingPath("JoeStrong2") }}
    var fbRoot = Firebase(url:"https://lifttracker2.firebaseio.com")

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
        var bodypartsNode = fbTestRoot.childByAppendingPath("bodyparts")
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
        let oneRepNode = fbTestUser.childByAppendingPath("exercises/benchpress/prs/1")
        oneRepNode.childByAppendingPath("2015-07-01").setValue(225)
        oneRepNode.childByAppendingPath("2015-07-05").setValue(250)
        //oneRepNode.childByAppendingPath("2015-07-10").setValue(240)
        oneRepNode.childByAppendingPath("2015-07-10").setValue(210, withCompletionBlock: { _ in
            //go fetch it
            oneRepNode.queryOrderedByValue().observeEventType(.Value, withBlock: { (result) in
                for child in result.children {
                    println("key:\(child.key!)")
                }
                done = true
            })
        })
        
        waitUntil(5) { done }
    }
    
    func testAllPrsForExercise() {
        var done = false
        let prs = fbTestUser.childByAppendingPath("/exercises/benchpress/prs")
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
            println(result)
            for x in result.children {
                println(x)
            }
            done = true
        })
        
        waitUntil(5) { done }
    }
    
    func testClearPr() {
        var done = false
        
        let prs = fbTestUser.childByAppendingPath("/exercises/benchpress/prs")
        //this wont work if values are left in PR
        prs.removeValueWithCompletionBlock( { _ in
            let oneRepNode = prs.childByAppendingPath("1")
            oneRepNode.childByAppendingPath("2015-07-01").setValue(225)
            oneRepNode.childByAppendingPath("2015-07-05").setValue(250)
            
            oneRepNode.childByAppendingPath("2015-07-05").removeValueWithCompletionBlock( { (result) in
                FirebaseHelper.getPrs(self.fbTestRoot, exercise: "benchpress", completion: { (result) in
                    println(result)
                    XCTAssertNotNil(result[1], "1 rep dictionary should have been there")
                    XCTAssertNil(result[1]!["2015-07-05"], "2015-07-05 should have been removed")
                    done = true
                })
            })
            
            self.waitUntil(5) { done }
        })
    }
    
    
    func test() {
        var node = fbTestRoot.childByAppendingPath("main")
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
    
    func testImportExercisesToUser() {
        var done = false
        println((fbTestRoot.description(),fbTestUser.description()))
        FirebaseImporter.importToUser([SeedData.Bodyparts, SeedData.Exercises], fbRoot: fbRoot, fbUser: fbTestUser) {
            done = true
        }
        waitUntil(5) { done }
    }
}