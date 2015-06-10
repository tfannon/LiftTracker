//
//  Importer.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/8/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import RealmSwift

class Importer {
    func importSeedDataIfNeeded() {
        importJson("Bodypart")
        importJson("Exercise")
        importJson("BodypartExercise")
    }
    
    func importJson(name : String) {
        let realm = Realm()
        var error: NSError? = nil
        let jsonURL = NSBundle.mainBundle().URLForResource(name, withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        let jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSArray
        
        realm.beginWrite()
        for x in jsonArray {
            switch(name) {
                case "Exercise" : realm.create(RExercise.self, value: x, update: true)
                case "Bodypart" : realm.create(RBodypart.self, value: x, update: true)
            case "BodypartExercise" :
                println(x)
                for jsonDictionary in jsonArray {
                    
                    let bodypartName = jsonDictionary["bodypart"] as! String
                    let exerciseName = jsonDictionary["exercise"] as! String
                    //println("\(bodypartName) - \(exerciseName)")
                }
                default:""
            }
        }
        realm.commitWrite()
    }
}
