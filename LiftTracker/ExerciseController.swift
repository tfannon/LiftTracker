//
//  ExerciseController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit
import CoreData

class ExerciseController: UICollectionViewController {
    
    let cellIdentifier = "ExerciseCell"
    let firebase = AppDelegate.get.firebase
    
    //var coreData : CoreDataStack!
    /*
    var fetchedResultsController : NSFetchedResultsController!
    var objectChanges : Array<Dictionary<NSFetchedResultsChangeType, (NSIndexPath,NSIndexPath?)>>!
    var sectionChanges : Array<Dictionary<NSFetchedResultsChangeType, Int>>!
    let fetchRequest = NSFetchRequest(entityName: "Bodypart")
    */
    var bodypart : Bodypart!
    
    lazy var exercises : [Exercise] = {
        var result = [Exercise]()
        for x in self.bodypart.exercises {
            result.append(x as! Exercise)
        }
        return result
    }()
    

   
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView(frame:self.view.bounds)
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imageView.image = UIImage(named: "dumbells.jpg")!
        self.view.insertSubview(imageView, atIndex: 0)
        
        addTitleBar()
        
        self.addButton("+", action: "addNewExercise")
        
        //the long press will trigger a delete for now
        var swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeLeft:")
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        collectionView!.addGestureRecognizer(swipeLeftRecognizer)

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        //self.coreData = AppDelegate.get.coreDataStack
        self.collectionView!.reloadData()
        //todo: refresh the view
        
    }
    
    func handleSwipeLeft(recognizer : UISwipeGestureRecognizer) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    
    func addTitleBar() {
        self.navigationItem.title = bodypart.name
    }
    
    func addNewExercise() {
        println("add called")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    /* In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var bo
        (segue.destinationViewController as ExerciseController).
    }
    */
    

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ExerciseCell
        cell.title.text = exercises[indexPath.row].name
        return cell
    }
    
    /*
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "ExerciseHeaderView",
                    forIndexPath: indexPath)
                    as ExerciseHeaderView
                headerView.title.text = exerciseTypes[indexPath.section]
                return headerView
            default:
                assert(false, "Unexpected element kind")
        }
    }
    */

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
