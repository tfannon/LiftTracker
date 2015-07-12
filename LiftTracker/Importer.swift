//
//  Importer.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/8/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
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
        let jsonURL = NSBundle.mainBundle().URLForResource(name, withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        do
        {
            let object:AnyObject? = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments)
            return object as! NSArray
        } catch let caught as NSError {
            print(caught)
            return []
        } catch {
            return []
        }
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
            overwrite = false
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
                
            case "BodypartExercise" : ""
                let root = firebase.childByAppendingPath("bodyparts")
                let bodypart = dict["bodypart"] as! String,
                    exercise = dict["exercise"] as! String,
                    displayOrder = dict["displayOrder"] as! Int
                
                let childKey = "\(bodypart.removeWhitespace().lowercaseString)/exercises/\(exercise.removeWhitespace().lowercaseString)"
                let node = root.childByAppendingPath(childKey)
                node.setValue(displayOrder)
            default:""
            }
        }
    }
}

