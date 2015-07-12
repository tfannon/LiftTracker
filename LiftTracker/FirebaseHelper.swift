//
//  FirebaseHelper.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/10/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

public class FirebaseHelper {
    static var RootRef = Firebase(url:"https://lifttracker2.firebaseio.com/main")
    
    public static func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    public static func getPrs(firebase : Firebase, exercise : String, completion: (result:[Int:[String:Double]]) -> Void)   {
        let firebasePr = firebase.childByAppendingPath("/exercises/\(exercise)/prs")
        println(firebasePr.description())
      
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
}