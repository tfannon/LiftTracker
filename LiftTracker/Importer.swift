//
//  Importer.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/8/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import RealmSwift


public class BaseImporter {
    
    public func importSeedDataIfNeeded() {
        importJson("Bodypart")
        importJson("Exercise")
        importJson("BodypartExercise")
    }
    
    public func importJson(name : String) {
        preconditionFailure("This method must be overridden")
    }
    
    
    func readJson(name : String) -> NSArray {
        var error: NSError? = nil
        let jsonURL = NSBundle.mainBundle().URLForResource(name, withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        let jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSArray
        return jsonArray
    }
}

public class RealmImporter : BaseImporter {

    override public func importJson(name : String) {
        let jsonArray = readJson(name)
        var exercises : [RExercise]
        var bodyparts : [RBodypart]
        let realm = Realm()
        realm.beginWrite()
        for dict in jsonArray as! [NSDictionary] {
            switch(name) {
            case "Exercise" : realm.create(RExercise.self, value: dict, update: true)
            case "Bodypart" : realm.create(RBodypart.self, value: dict, update: true)
            case "BodypartExercise" :
                let bp = dict["bodypart"] as! String,
                    ex = dict["exercise"] as! String
                
                println("\(bp) \(ex)")
                    //let bodypartName = kvp.key as! String
                    //let exerciseName = kvp.value["exercise"] as! String
                    //println("\(bodypartName) - \(exerciseName)")
                let exercise = realm.objectForPrimaryKey(RExercise.self, key: ex),
                    bodypart = realm.objectForPrimaryKey(RBodypart.self, key: bp)
                    //    println("\(bodypart.name) - \(exercise.name)")
                 bodypart!.exercises.append(exercise!)
                    //}
                
            default:""
            }
        }
        realm.commitWrite()
    }
    
    public override init() {
    }
}

/*
class FirebaseImporter : BaseImporter {
    var firebase : Firebase!

    init(url : String) {
        firebase = Firebase(url: url)
    }

    override func importJson(name: String) {
        let jsonArray = readJson(name)
        for x in jsonArray {
            switch(name) {
            default:""
            }
        }
    }
}
*/
