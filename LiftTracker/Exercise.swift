//
//  Exercise.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 1/5/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import CoreData

class Exercise: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var isSystem: Bool
    @NSManaged var displayOrder: Int32

}
