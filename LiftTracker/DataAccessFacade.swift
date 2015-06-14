//
//  DataAccessFacade.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/12/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

enum DataAccessType {
    case CoreData
    case Realm
    case Firebase
}

var dataAccess : DataAccessType = .Firebase




