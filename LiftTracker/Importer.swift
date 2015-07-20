//
//  Importer.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/8/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation



public class BaseImporter {

    public func importSeedData() {
        importJson(FBNodeType.Bodyparts)
        importJson(FBNodeType.Exercises)
        importJson(FBNodeType.BodypartsToExercises)
    }
    
    func importJson(type: FBNodeType) {
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

public class FirebaseImporter : BaseImporter {
    var firebase : Firebase!
    
    public init(root : Firebase) {
        firebase = root
    }
    
    override func importJson(type: FBNodeType) {
        var fileName = ""
        var nodeName = ""
        switch type {
        case .Bodyparts :
            fileName = "Bodyparts"
            nodeName = type.rawValue
        case .Exercises :
            fileName = "Exercises"
            nodeName = type.rawValue
        case .BodypartsToExercises :
            fileName = "BodypartsToExercises"
        default :
            println("\(type) is invalid for import")
            abort()
        }
        let jsonArray = readJson(fileName)
        for dict in jsonArray as! [NSDictionary] {
            switch(type) {
            case .Exercises, .Bodyparts :
                let node = firebase.childByAppendingPath(nodeName)
                let name = dict["name"] as! String
                let child = node.childByAppendingPath(name.removeWhitespace().lowercaseString)
                child.setValue(dict)
            case .BodypartsToExercises :
                var node = firebase.childByAppendingPath(FBNodeType.Bodyparts.rawValue)
                let bodypart = dict["bodypart"] as! String,
                    exercise = dict["exercise"] as! String,
                    displayOrder = dict["displayOrder"] as! Int
                
                let childKey = "\(bodypart.removeWhitespace().lowercaseString)/exercises/\(exercise.removeWhitespace().lowercaseString)"
                node = node.childByAppendingPath(childKey)
                node.setValue(displayOrder)
            default:""
            }
        }
    }
    
    public static func setupNewUser(fbRoot : Firebase, fbUser : Firebase, completion: () ->()) {
        importToUser([.Exercises,.Bodyparts,], fbRoot: fbRoot, fbUser: fbUser, completion: completion)
    }

    
    public static func importToUser(types : [FBNodeType], fbRoot : Firebase, fbUser : Firebase, completion: () ->()) {
        let group = dispatch_group_create()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

        //do not exit this thread until all data has been setup and completions have been fired
        for type in types {
            dispatch_group_enter(group)
            let node = fbRoot.childByAppendingPath(type.rawValue)
            let userNode = fbUser.childByAppendingPath(type.rawValue)
            node.observeSingleEventOfType(.Value, withBlock: { result in
                let enumerator = result.children
                println("getting ready to leave group")
                dispatch_group_leave(group)
                while let child = enumerator.nextObject() as? FDataSnapshot {
                    println(child.key!, child.value!)
                    let key = child.key
                    let val = child.value! as! [NSObject : AnyObject]
                    let userNodeChild = userNode.childByAppendingPath(key)
                    userNodeChild.updateChildValues(val)
                }
            })
        }
        //i am awesome.  i can haz thredz
        dispatch_group_notify(group, queue) {
            completion()
        }
    }
}
