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
        let exercise = RExercise(name: "Squat")
        let pr1 = PR(parent: exercise, reps:6, weight:125)
        exercise.prs.append(pr1)
        
        let pr2 = PR(parent: exercise, reps:5, weight:140)
        exercise.prs.append(pr2)
        
        //test that each exercise can have its own unique value for a rep
        let exercise2 = RExercise(name: "Bench Press")
        let pr3 = PR(parent: exercise2, reps: 5, weight: 95, date: NSDate().dateBySubtractingDays(4))
        exercise2.prs.append(pr3)
        
        let realm = Realm()
        realm.write {
            realm.add(exercise)
            realm.add(exercise2)
        }
        
        //update the 5 rep pr for squat
        realm.write {
            pr2.weight = 150
        }
        
        let pr4 = PR(parent: exercise2,reps: 4, weight: 100)
        realm.write {
            exercise2.prs.append(pr4)
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
        
        let benchPR = PR(parent: exercise2, reps: 3, weight: 205)
        exercise2.prs.append(benchPR)
        
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
    
    func testImporter() {
        var importer = RealmImporter()
        importer.importSeedDataIfNeeded()
        let exercises = Realm().objects(RExercise)
        let bodyparts = Realm().objects(RBodypart)
        XCTAssertEqual(6, bodyparts.count)
        XCTAssertEqual(7, exercises.count)
        var chest =  Realm().objectForPrimaryKey(RBodypart.self, key: "Chest")!
        println(chest)
        XCTAssertEqual(2, chest.exercises.count)
    }
    
}
        