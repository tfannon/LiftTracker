//
//  ViewController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit
import CoreData

class BodypartController: UICollectionViewController, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {

    let cellIdentifier = "BodypartCell"
    
    var coreData : CoreDataStack!
    var fetchedResultsController : NSFetchedResultsController!
    //UICollectionView does not work exactly like UITableView with FetchedResultsController so we have to track changes
    var objectChanges : Array<Dictionary<NSFetchedResultsChangeType, (NSIndexPath,NSIndexPath?)>>!
    var sectionChanges : Array<Dictionary<NSFetchedResultsChangeType, Int>>!
    let fetchRequest = NSFetchRequest(entityName: "Bodypart")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView(frame:self.view.bounds)
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imageView.image = UIImage(named: "dumbells.jpg")!
        self.view.insertSubview(imageView, atIndex: 0)
        
        //todo: can we put this in the storyboard???
        let addButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 88, UIScreen.mainScreen().bounds.size.width, 44))
        addButton.setTitle("+", forState: .Normal)
        addButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        addButton.addTarget(self, action: "addNewItem", forControlEvents: .TouchUpInside)
        self.view.addSubview(addButton)
        
        //the long press will trigger a delete for now
        var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.delaysTouchesBegan = true //so wont interfere with normal tap
        collectionView!.addGestureRecognizer(longPressGestureRecognizer)
        
        self.coreData = AppDelegate.get.coreDataStack
        objectChanges = Array<Dictionary<NSFetchedResultsChangeType, (NSIndexPath,NSIndexPath?)>>()
        sectionChanges = Array<Dictionary<NSFetchedResultsChangeType, Int>>()
        fetchData()
    }
    
    func handleLongPress(recognizer : UILongPressGestureRecognizer) {
        if recognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        let p = recognizer.locationInView(self.collectionView!)
        if let indexPath = collectionView!.indexPathForItemAtPoint(p) {
            let cell = collectionView!.cellForItemAtIndexPath(indexPath) as! BodypartCell
            deleteItem(cell.title.text!, indexPath:indexPath)
        }
        else {
            println("could not find cell for longpress")
        }
    }
    
    private func fetchData() {
        //1
        //let fetchRequest =
        
        let sort = NSSortDescriptor(key: "displayOrder", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        //2
        fetchedResultsController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                managedObjectContext: coreData.context,
                sectionNameKeyPath: nil,
                cacheName: "Bodypart")
        
        fetchedResultsController.delegate = self
        
        //3
        var error: NSError? =  nil
        if (!fetchedResultsController.performFetch(&error)) {
            println("Error fetching Bodyparts: \(error?.localizedDescription)")
        }
    }
    
    func addNewItem() {
        var alert = UIAlertController(title: "Bodypart",
            message: "Add a new bodypart",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "Bodypart"
        }
        
        alert.addAction(UIAlertAction(title: "Save",
            style: .Default, handler: { (action: UIAlertAction!) in
                let nameTextField = alert.textFields![0] as! UITextField
                
                let bodypart =
                NSEntityDescription.insertNewObjectForEntityForName("Bodypart",
                    inManagedObjectContext: self.coreData.context) as! Bodypart
                
                bodypart.name = nameTextField.text
                //right now insert it at the end of the list
                //there is an issue with delete and the index is screwed up?
                let count = self.coreData.context.countForFetchRequest(self.fetchRequest, error: nil)
                bodypart.displayOrder = count
                self.coreData.saveContext()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
            style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(alert, animated: true, completion: nil)

    }
    
    func deleteItem(title : String, indexPath : NSIndexPath) {
        var alert = UIAlertController(title: "",
            message: "Do you want to delete \(title)?",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Delete",
            style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction!) in
                let bodypart = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Bodypart
                
                self.coreData.context.deleteObject(bodypart)
                self.coreData.saveContext()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
            style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! ExerciseController
        var indexPath = self.collectionView!.indexPathsForSelectedItems()[0] as! NSIndexPath
        var bodypart = fetchedResultsController.objectAtIndexPath(indexPath) as! Bodypart
        println(bodypart)
        dest.bodypart = bodypart
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! BodypartCell
        let bodypart = fetchedResultsController.objectAtIndexPath(indexPath) as! Bodypart
        cell.title.text = bodypart.name
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return bodyparts.count
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int,
                    forChangeType type: NSFetchedResultsChangeType) {
      
        var change = Dictionary<NSFetchedResultsChangeType, Int>()
        switch type {
        case .Insert:
            change[type] = sectionIndex
        case .Delete:
            change[type] = sectionIndex
        default :
            break
        }
        sectionChanges.append(change)
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath!,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath!) {
            
        var change = Dictionary<NSFetchedResultsChangeType, (NSIndexPath, NSIndexPath?)>()
        switch type {
        case .Insert:
            change[type] = (newIndexPath,nil)
        case .Delete:
            change[type] = (indexPath,nil)
        case .Update:
            change[type] = (indexPath,nil)
        case .Move:
            change[type] = (indexPath,newIndexPath)
        default:
            break
        }
        objectChanges.append(change)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        
        if sectionChanges.count > 0 {
            self.collectionView!.performBatchUpdates({
                for change in self.sectionChanges {
                    for (type,val) in change {
                        switch (type) {
                        case NSFetchedResultsChangeType.Insert :
                            self.collectionView!.insertSections(NSIndexSet(index: val))
                        case NSFetchedResultsChangeType.Delete :
                            self.collectionView!.deleteSections(NSIndexSet(index: val))
                        case NSFetchedResultsChangeType.Update :
                            self.collectionView!.reloadSections(NSIndexSet(index: val))
                        case NSFetchedResultsChangeType.Move :
                            println("section move not handled")
                        default:""
                            break
                        }
                    }
                    
                }
            }, completion: nil)
        }
        
        if objectChanges.count > 0 && sectionChanges.count == 0 {
            
            //            if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            //                // This is to prevent a bug in UICollectionView from occurring.
            //                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            //                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            //                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            //                // http://openradar.appspot.com/12954582
            //                [self.collectionView reloadData];
            
            self.collectionView!.performBatchUpdates({
                for change in self.objectChanges {
                    for (type,val:(NSIndexPath, NSIndexPath?)) in change {
                        switch (type) {
                        case NSFetchedResultsChangeType.Insert :
                            self.collectionView!.insertItemsAtIndexPaths([val.0])
                        case NSFetchedResultsChangeType.Delete :
                            self.collectionView!.deleteItemsAtIndexPaths([val.0])
                        case NSFetchedResultsChangeType.Update :
                            self.collectionView!.reloadItemsAtIndexPaths([val.0])
                        case NSFetchedResultsChangeType.Move :
                            self.collectionView!.deleteItemsAtIndexPaths([val.0])
                            self.collectionView!.insertItemsAtIndexPaths([val.1!])
                        default:""
                            break
                        }
                    }
                }
            }, completion: nil)
        }
        
        sectionChanges.removeAll(keepCapacity: true)
        objectChanges.removeAll(keepCapacity: true)
    }
}

