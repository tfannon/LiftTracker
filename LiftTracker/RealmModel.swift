//
//  RealmModel.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 5/28/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import RealmSwift
import Foundation

public class RBodypart : Object {
    dynamic var name = ""
    dynamic var displayOrder = 0
    dynamic var isSystem = true
    let exercises = List<RExercise>()
    
    override public static func primaryKey() -> String? {
        return "name"
    }
}

public class RExercise : Object {
    dynamic var name = ""
    dynamic var isSystem = true
    let prs = List<PR>()
    
    override public static func primaryKey() -> String? {
        return "name"
    }
}

public class PR : Object {
    dynamic var id : String = ""
    dynamic var reps : Int = 0
    dynamic var weight : Int = 0
    dynamic var date = NSDate()
    
    convenience public init(parent : RExercise, reps : Int) {
        self.init()
        self.id = "\(parent.name).\(reps)"
        self.reps = reps
    }
    
    convenience public init(parent : RExercise, reps : Int, weight : Int) {
        self.init(parent: parent, reps: reps)
        self.weight = weight
    }

    required public init() {
        super.init()
    }

    override public static func primaryKey() -> String? {
        return "id"
    }
}