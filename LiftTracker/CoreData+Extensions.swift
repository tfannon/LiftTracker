//
//  CoreData+Extensions.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 2/18/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import CoreData


public extension Bodypart {
    /*
    public convenience init(context: NSManagedObjectContext, name : String) {
        let entityDescription = NSEntityDescription.entityForName("Exercise", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
        self.name = name
    }
    */
    
    public func addExercise(value : Exercise) {
        var items = self.mutableSetValueForKey("exercises")
        items.addObject(value)
    }
    
    public func removeExercise(value : Exercise) {
        var items = self.mutableSetValueForKey("exercises")
        items.removeObject(value)
    }
}
