//
//  AppDelegate.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        importJSONSeedDataIfNeeded()
        println(bodyparts)
        println(exercises)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }
    
    class var get : AppDelegate {
        return (UIApplication.sharedApplication().delegate! as! AppDelegate)
    }
    
    var bodyparts = [String:Bodypart]()
    var exercises = [String:Exercise]()
    let clearData = false
    
    //MARK: seed data
    func importJSONSeedDataIfNeeded() {
        getJsonData("Bodypart")
        getJsonData("Exercise")
        mapBodypartToExercise("BodypartExercise")
    }
    
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
    
    func mapBodypartToExercise(name : String) {
        if bodyparts.count == 0 || exercises.count == 0 {
            return
        }
        
        var error: NSError? = nil
        let jsonURL = NSBundle.mainBundle().URLForResource(name, withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)
        let jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSArray
        importJson(name, jsonArray:jsonArray)
        
    }
    
    func importJson(entityName : String, jsonArray : NSArray) {
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: coreDataStack.context)
        switch entityName {
        case "Bodypart":
            for jsonDictionary in jsonArray {
                let name = jsonDictionary["name"] as! String
                let isSystem = jsonDictionary["isSystem"] as! Bool
                let displayOrder = jsonDictionary["displayOrder"] as! Int
                let bodypart = Bodypart(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
                bodypart.name = name
                bodypart.isSystem = isSystem
                bodypart.displayOrder = displayOrder
                coreDataStack.saveContext()
                bodyparts[name] = bodypart
            }
        case "Exercise":
            for jsonDictionary in jsonArray {
                let name = jsonDictionary["name"] as! String
                let isSystem = jsonDictionary["isSystem"] as! Bool
                let exercise = Exercise(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
                exercise.name = name
                exercise.isSystem = isSystem
                coreDataStack.saveContext()
                exercises[name] = exercise
            }
        case "BodypartExercise":
            //println(bodyparts)
            //println(exercises)
            for jsonDictionary in jsonArray {
                let bodypartName = jsonDictionary["bodypart"] as! String
                let exerciseName = jsonDictionary["exercise"] as! String
                let displayOrder = jsonDictionary["displayOrder"] as! Int
                println("\(bodypartName) - \(exerciseName):  \(displayOrder)")
                if let bodypart = bodyparts[bodypartName] {
                    if let exercise = exercises[exerciseName] {
                        //println("\(bodypart.name):\(exercise.name)")
                        bodypart.addExercise(exercise)
                        coreDataStack.saveContext()
                        continue
                    }
                }
                println("problem with \(bodypartName):\(exerciseName)")
                abort()
            }

        default:
            println("there is a problem")
        }
       
        println("Imported \(jsonArray.count) \(entityName)s")
    }
    
   
    /*
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.crazy8dev.LiftTracker" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("LiftTracker", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("LiftTracker.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    */

}

