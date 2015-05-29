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
    
    func testBodypartExercises() {
        let bodypart = RBodypart()
        bodypart.name = "Chest"
        
        let exercise = RExercise()
        exercise.name = "Dumbell presses"
        
        let exercise2 = RExercise()
        exercise2.name = "Bench Press"
        
        bodypart.exercises.extend([exercise, exercise2])
        
        let realm = Realm()
        realm.write {
            realm.add(bodypart)
            realm.add(exercise)
            realm.add(exercise2)
        }
        
        let exercises = Realm().objects(RExercise)
        let bodyparts = Realm().objects(RBodypart)
        XCTAssertEqual(1, bodyparts.count)
        XCTAssertEqual(2, exercises.count)
        XCTAssertEqual(2, bodypart.exercises.count)

    }
}
        