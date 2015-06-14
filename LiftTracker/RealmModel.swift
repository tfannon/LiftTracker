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
    public dynamic var name = ""
    public dynamic var displayOrder = 0
    public dynamic var isSystem = false
    public let exercises = List<RExercise>()
    
    convenience public init(name : String) {
        self.init()
        self.name = name
    }
    
    override public static func primaryKey() -> String? {
        return "name"
    }
}

public class RExercise : Object {
    public dynamic var name = ""
    public dynamic var isSystem = true
    public let prs = List<PR>()
    
    convenience public init(name : String) {
        self.init()
        self.name = name
    }
    
    override public static func primaryKey() -> String? {
        return "name"
    }
}

public class PR : Object {
    public dynamic var id : String = ""
    public dynamic var reps : Int = 0
    public dynamic var weight : Int = 0
    public dynamic var date = NSDate()
    
    convenience public init(parent : RExercise, reps : Int) {
        self.init()
        self.id = "\(parent.name).\(reps)"
        self.reps = reps
    }
    
    convenience public init(parent : RExercise, reps : Int, weight : Int) {
        self.init(parent: parent, reps: reps)
        self.weight = weight
    }
    
    convenience public init(parent : RExercise, reps : Int, weight : Int, date : NSDate) {
        self.init(parent: parent, reps: reps, weight: weight)
        self.date = date
    }

    override public static func primaryKey() -> String? {
        return "id"
    }
}