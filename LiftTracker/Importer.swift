//
//  Importer.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/8/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData


public class BaseImporter {
    var overwrite : Bool = false
    
    public func importSeedDataIfNeeded(overwrite : Bool = false) {
        self.overwrite = overwrite
        importJson("Bodypart")
        importJson("Exercise")
        importJson("BodypartExercise")
    }
    
    func importJson(name : String) {
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

    public override init() {
    }

    override func importJson(name : String) {
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
}


public class FirebaseImporter : BaseImporter {
    var firebase : Firebase!

    public init(root : Firebase) {
        firebase = root
    }

    override func importJson(name: String) {
        if overwrite {
            firebase.removeValue()
        }
        let jsonArray = readJson(name)
        for dict in jsonArray as! [NSDictionary] {
            switch(name) {
            case "Exercise" :
                let root = firebase.childByAppendingPath("exercises")
                let name = dict["name"] as! String
                let node = root.childByAppendingPath(name.removeWhitespace().lowercaseString)
                node.setValue(dict)
            case "Bodypart" :
                let root = firebase.childByAppendingPath("bodyparts")
                let name = dict["name"] as! String
                let node = root.childByAppendingPath(name.removeWhitespace().lowercaseString)
                node.setValue(dict)
                
            case "BodypartExercise" :
                let root = firebase.childByAppendingPath("bodyparts")
                let bodypart = dict["bodypart"] as! String,
                    exercise = dict["exercise"] as! String
                let childKey = "\(bodypart.removeWhitespace().lowercaseString)/exercises/\(exercise.removeWhitespace().lowercaseString)"
                var node = root.childByAppendingPath(childKey)
                node.setValue(true)
            default:""
            }
        }
    }
}


public class CoreDataImporter : BaseImporter {
    
    var bodyparts = [String:Bodypart]()
    var exercises = [String:Exercise]()
    let clearData = false
    lazy var coreDataStack = CoreDataStack()
    
    
    override func importJson(name: String) {
        let jsonArray = readJson(name)
        for dict in jsonArray as! [NSDictionary] {
            let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: coreDataStack.context)
            switch(name) {
            case "Exercise":
                let exercise = Exercise(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
                exercise.name = dict["name"] as! String
                exercise.isSystem = dict["isSystem"] as! Bool
                coreDataStack.saveContext()
                exercises[name] = exercise
            case "Bodypart":
                let bodypart = Bodypart(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
                bodypart.name = dict["name"] as! String
                bodypart.isSystem = dict["isSystem"] as! Bool
                bodypart.displayOrder = dict["displayOrder"] as! Int
                coreDataStack.saveContext()
                bodyparts[name] = bodypart
            case "BodypartExercise":
                let bodypartName = dict["bodypart"] as! String
                let exerciseName = dict["exercise"] as! String
                let displayOrder = dict["displayOrder"] as! Int
                println("\(bodypartName) - \(exerciseName):  \(displayOrder)")
                if let bodypart = bodyparts[bodypartName],
                       exercise = exercises[exerciseName] {
                    println("\(bodypart.name):\(exercise.name)")
                    bodypart.addExercise(exercise)
                    coreDataStack.saveContext()
                    continue
                }
                println("problem with \(bodypartName):\(exerciseName)")
                abort()
            default:
                println("there is a problem")
            }
        }
    }

    /*
    func getJsonData(name : String) {
        let fetchRequest = NSFetchRequest(entityName: name)
        var error: NSError? = nil
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        //todo: set cleardata flag to false when we are ready to keep data around
        if (results == 0 || clearData) {
            var fetchError: NSError? = nil
            if let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError) {
                for object in results {
                    coreDataStack.context.deleteObject(object as! NSManagedObject)
                }
            }
            coreDataStack.saveContext()
            let jsonURL = NSBundle.mainBundle().URLForResource(name, withExtension: "json")
            let jsonData = NSData(contentsOfURL: jsonURL!)
            let jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSArray
            importJson(name, jsonArray:jsonArray)
        }
        //        else {
        //            let bodyparts = coreDataStack.fetch2(name) as [Bodypart]
        //            println(bodyparts)
        //        }
    }
    */
}
