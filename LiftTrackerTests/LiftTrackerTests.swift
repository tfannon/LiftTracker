//
//  LiftTrackerTests.swift
//  LiftTrackerTests
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit
import XCTest
import LiftTracker
import CoreData

class LiftTrackerTests: XCTestCase {
    
    var moc = NSManagedObjectContext()
    
    override func setUp() {
        super.setUp()
        var mmol = NSManagedObjectModel.mergedModelFromBundles(nil)
        var psc = NSPersistentStoreCoordinator(managedObjectModel: mmol!)
        var pstore = NSPersistentStore()
        pstore = psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)!
        moc.persistentStoreCoordinator = psc
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testExercise() {
        var entity = NSEntityDescription.entityForName("Exercise", inManagedObjectContext: moc)
        let exercise = Exercise(entity: entity!, insertIntoManagedObjectContext: moc)
        exercise.name = "Bench Press"
        moc.save(nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
