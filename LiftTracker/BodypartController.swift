//
//  ViewController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit
import CoreData

class BodypartController: UICollectionViewController,  UIGestureRecognizerDelegate {

    let cellIdentifier = "BodypartCell"
    var firebase = AppDelegate.get.firebase
   
    //tuple:  KVP of key->bodypart Name
    var bodyparts:[(key: String, name: String)] = []

    
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
        
        fetchDataFromFirebase()
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
    
    func fetchDataFromFirebase() {
        bodyparts.removeAll()
        let node = firebase.childByAppendingPath("bodyparts")
        node.queryOrderedByChild("displayOrder").observeSingleEventOfType(.Value, withBlock: { result in
            //println(result)
            let enumerator = result.children
            while let child = enumerator.nextObject() as? FDataSnapshot {
                //println(child.value)
                let name = (child.value as! NSDictionary) ["name"] as! String
                self.bodyparts += [(key: child.key!, name: name)]
            }
            println(self.bodyparts)
            self.collectionView?.reloadData()
        })
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
                let name = (alert.textFields![0] as! UITextField).text
                let key = name.removeWhitespace().lowercaseString
                let keys = self.bodyparts.map { $0.key }
                if  find(keys,key) == nil {
                    let order = self.bodyparts.count
                    var dict = [String:AnyObject]()
                    dict["displayOrder"] = order
                    dict["isSystem"] = false
                    dict["name"] = name
                    let node = self.firebase.childByAppendingPath("bodyparts/\(key)")
                    node.setValue(dict, withCompletionBlock: { (error,result) in
                        println(result)
                        self.fetchDataFromFirebase()
                    })
                }
                else {
                }
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
                let key = self.bodyparts[indexPath.row].key
                let node = self.firebase.childByAppendingPath("bodyparts/\(key)")
                node.removeValueWithCompletionBlock {(result) in
                    println(result)
                    self.fetchDataFromFirebase()
                }
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
        //var bodypart = fetchedResultsController.objectAtIndexPath(indexPath) as! Bodypart
        //println(bodypart)
        dest.bodypart = bodyparts[indexPath.row]
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! BodypartCell
        cell.title.text = bodyparts[indexPath.row].name
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bodyparts.count
    }
}

