//
//  FirebaseHelper.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/10/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

public typealias LogEntries = [Int:[String:Double]]

public class FirebaseHelper {
    
    
    
    public static func getPrs(firebase : Firebase, exercise : String, completion: (result:[Int:[String:Double]]) -> Void)   {
        let firebasePr = firebase.childByAppendingPath("/\(FBNodeType.Exercises.rawValue)/\(exercise)/prs")
        //println(firebasePr.description())
      
        firebasePr.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { (result) in
            var prs = [Int:[String:Double]]()
            for x in result.children {
                let repSnap = x as! FDataSnapshot
                let rep = repSnap.key.toInt()!
                if prs[rep] == nil {
                    prs[rep] = [String:Double]()
                }
                //println(repSnap)
                var dateDict = [String:Double]()
                for y in repSnap.children {
                    let dateSnap = y as! FDataSnapshot
                    //println(dateSnap)
                    dateDict[dateSnap.key] = dateSnap.value as? Double
                    //println(dateDict)
                    prs[rep] = dateDict
                }
            }
            completion(result: prs)
        })
    }
    
    public static func getPRForRep(entries : LogEntries, rep : Int) -> (date: String, weight: Double)? {
        if let node = entries[rep] {
            var largestDate : String = ""
            var largestWeight : Double = 0
            for (date,weight) in node {
                if weight > largestWeight {
                    largestWeight = weight
                    largestDate = date
                }
            }
            if largestWeight > 0 {
                return (largestDate, largestWeight)
            }
        }
        return nil
    }
    
    
    public static func updateLastLogin(user : Firebase) {
        let node = user.childByAppendingPath(FBNodeType.UserInfo.rawValue)
        node.updateChildValues([FBNodeType.LastLogin.rawValue : NSDate().toIsoString()])
    }
    
    public static func updateDisplayName(user : Firebase, displayName : String) {
        let node = user.childByAppendingPath(FBNodeType.UserInfo.rawValue)
        node.updateChildValues([FBNodeType.DisplayName.rawValue : displayName])
    }
}