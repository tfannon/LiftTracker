//
//  Bodypart.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 2/18/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import CoreData

@objc(Bodypart)
public class Bodypart: NSManagedObject {

    @NSManaged public var displayOrder: NSNumber
    @NSManaged public var isHidden: NSNumber
    @NSManaged public var isSystem: NSNumber
    @NSManaged public var name: String
    @NSManaged public var exercises: NSSet

}
