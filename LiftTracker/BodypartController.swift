//
//  ViewController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit
import CoreData

class BodypartController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    let bodyparts = ["Chest", "Shoulders", "Arms", "Back", "Legs", "Other"]
    let cellIdentifier = "BodypartCell"
    
    var coreData : CoreDataStack!
    var fetchedResultsController : NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView(frame:self.view.bounds)
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imageView.image = UIImage(named: "dumbells.jpg")!
        self.view.insertSubview(imageView, atIndex: 0)
        
        let addButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 88, UIScreen.mainScreen().bounds.size.width, 44))
        addButton.setTitle("+", forState: .Normal)
        addButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        addButton.addTarget(self, action: "addNewItem", forControlEvents: .TouchUpInside)
        self.view.addSubview(addButton)
        
        self.coreData = AppDelegate.get.coreDataStack
        fetchData()
    }
    
    private func fetchData() {
        //1
        let fetchRequest = NSFetchRequest(entityName: "Bodypart")
        
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
    
    
     // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as BodypartCell
        let bodypart = fetchedResultsController.objectAtIndexPath(indexPath) as Bodypart
        //cell.title.text = bodyparts[indexPath.row]
        cell.title.text = bodypart.name
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return bodyparts.count
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
}

