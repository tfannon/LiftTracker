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
}