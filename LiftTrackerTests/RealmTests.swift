//
//  RealmTests.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 5/28/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit
import XCTest
import LiftTracker
import RealmSwift

class RealmTests: XCTestCase {

    lazy var realmPathForTesting : String = {
        let fileManager = NSFileManager.defaultManager()
        let documentURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last! as! NSURL
        let realmURL = documentURL.URLByAppendingPathComponent("tests.realm")
        println(realmURL)
        return realmURL.path!
    }()
    
    func deleteRealmFilesAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(path, error: nil)
        let lockPath = path + ".lock"
        fileManager.removeItemAtPath(lockPath, error: nil)
    }

    // In XCTestCase subclass:

    override func setUp() {
        super.setUp()
        deleteRealmFilesAtPath(realmPathForTesting)
        Realm.defaultPath = realmPathForTesting
    }

    override func tearDown() {
        super.tearDown()
        deleteRealmFilesAtPath(realmPathForTesting)
    }
    
    func testExercise() {
        let exercise = RExercise()
        exercise.name = "Dumbell presses"

        let realm = Realm()
        realm.write {
            realm.add(exercise)
        }
    }
    
    func testPRs() {
        let exercise = RExercise()
        exercise.name = "Squat"
        let pr1 = PR()
        pr1.rep = 6
        pr1.weight = 125
        exercise.prs.append(pr1)
        
        let pr2 = PR()
        pr2.rep = 5
        pr2.weight = 125
        exercise.prs.append(pr2)
        
        let exercise2 = RExercise()
        exercise2.name = "Bench Press"
        let pr3 = PR()
        pr3.rep = 8
        pr3.weight = 95
        pr3.date = NSDate().dateBySubtractingDays(4)
        exercise2.prs.append(pr3)
        
        
        let realm = Realm()
        realm.write {
            realm.add(exercise)
            realm.add(exercise2)
        }
    }
    
    
    func testBodypartExercises() {
        let bodypart = RBodypart()
        bodypart.name = "Chest"
        
        let bodypart2 = RBodypart()
        bodypart2.name = "Triceps"
        
        let exercise = RExercise()
        exercise.name = "Dumbell presses"
        
        let exercise2 = RExercise()
        exercise2.name = "Bench Press"
        
        bodypart.exercises.extend([exercise, exercise2])
        bodypart2.exercises.append(exercise2)
        
        let realm = Realm()
        realm.write {
            realm.add(bodypart)
            realm.add(bodypart2)
            realm.add(exercise)
            realm.add(exercise2)
        }
        
        let exercises = Realm().objects(RExercise)
        let bodyparts = Realm().objects(RBodypart)
        XCTAssertEqual(2, bodyparts.count)
        XCTAssertEqual(2, exercises.count)
        XCTAssertEqual(2, bodypart.exercises.count)
        XCTAssertEqual(1, bodypart2.exercises.count)

    }
    
    
    func testJson() {
        let realm = Realm()
        var error: NSError? = nil
        let jsonURL = NSBundle.mainBundle().URLForResource("Exercise", withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        let jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSArray
        realm.beginWrite()
        for x in jsonArray {
            realm.create(RExercise.self, value: x, update: true)
        }
        realm.commitWrite()
    }
    
    
}
        