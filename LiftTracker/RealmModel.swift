//
//  RealmModel.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 5/28/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import RealmSwift

class RBodypart : Object {
    dynamic var name = ""
    let exercises = List<RExercise>()
}

public class RExercise : Object {
    dynamic var name = ""
}