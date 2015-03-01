

import Foundation
import CoreData

public class CoreDataStack {
  
    public var context:NSManagedObjectContext
    public var psc:NSPersistentStoreCoordinator
    public var model:NSManagedObjectModel
    var store:NSPersistentStore?
  
    public init() {
    
        let bundle = NSBundle.mainBundle()
        let modelURL =
        bundle.URLForResource("LiftTracker", withExtension:"momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        psc = NSPersistentStoreCoordinator(managedObjectModel:model)
        
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc
        
        let documentsURL = applicationDocumentsDirectory()
        let storeURL =
        documentsURL.URLByAppendingPathComponent("LiftTracker")
        
        let options =
        [NSMigratePersistentStoresAutomaticallyOption: true]
        
        var error: NSError? = nil
        store = psc.addPersistentStoreWithType(NSSQLiteStoreType,
          configuration: nil,
          URL: storeURL,
          options: options,
          error:&error)
        
        if store == nil {
          println("Error adding persistent store: \(error)")
          abort()
        }
    }
  
    func saveContext() {
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
          println("Could not save: \(error), \(error?.userInfo)")
        }
    }
  
    func applicationDocumentsDirectory() -> NSURL {
    
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory,
          inDomains: .UserDomainMask) as Array<NSURL>
        return urls[0]
    }
    
    //todo: make this a generic function
    public func fetch(entityName : String) -> [AnyObject]? {
        let request = NSFetchRequest(entityName: entityName)
//        if name != nil {
//            request.predicate = NSPredicate(format: "name == %@", name!)
//        }
        var error: NSError?
        return context.executeFetchRequest(request, error: &error)
    }
    
    func fetch2(name : String) -> [NSManagedObject] {
        let request = NSFetchRequest(entityName: name)
        var e : NSError?
        if let results = context.executeFetchRequest(request, error: &e) as? [NSManagedObject] {
            return results
        } else {
            println("fetch error: \(e!.localizedDescription)")
            abort();
        }
    }
}