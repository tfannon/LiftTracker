//
//  ExerciseController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit


class ExerciseController: UICollectionViewController, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let cellIdentifier = "ExerciseCell"
    let firebase = AppDelegate.get.firebase
    
    var bodypart:(key: String, name: String)!
    var allExercises:[(key: String, name: String)] = []
    var bodypartExercises:[(key: String, name: String)] = []
    
    //will be alphabetized list of items not already found in bodypart exercises
    var exercisesValidForSelection:[(key: String, name: String)] = []

    
    var btnAddExercise : UIButton!
    var pickerHiddenTextField : UITextField!
    var picker : UIPickerView!
    var tapGesture : UITapGestureRecognizer!
    
    var indexOfAddNewExercise : Int {
        get {
            return exercisesValidForSelection.count
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView(frame:self.view.bounds)
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imageView.image = UIImage(named: "dumbells.jpg")!
        self.view.insertSubview(imageView, atIndex: 0)
        
        addTitleBar()
        
        self.btnAddExercise = self.addButton("+", action: "pickExercise")
        
        //the long press will trigger a delete
        var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.delaysTouchesBegan = true //so wont interfere with normal tap
        collectionView!.addGestureRecognizer(longPressGestureRecognizer)
        
        setupPickerView()
        
        //swipe left will return back to bodypart
        var swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeLeft:")
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        collectionView!.addGestureRecognizer(swipeLeftRecognizer)
        fetchGlobalExercises()
        fetchBodypart()
    }
    
    func setupPickerView() {
        pickerHiddenTextField = UITextField()
        self.view.addSubview(pickerHiddenTextField)
        picker = UIPickerView()
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        pickerHiddenTextField.inputView = picker
        //tapping anywhere outside picker exists
        self.tapGesture = UITapGestureRecognizer(target: self, action: "exitPicker")
     }
    
    
    
    func fetchGlobalExercises() {
        allExercises.removeAll()
        let node = firebase.childByAppendingPath("exercises")
        node.observeSingleEventOfType(.Value, withBlock: { result in
            let enumerator = result.children
            while let child = enumerator.nextObject() as? FDataSnapshot {
                let name = (child.value as! NSDictionary) ["name"] as! String
                self.allExercises += [(key: child.key!, name: name)]
            }
        })
    }
    
    func fetchBodypart() {
        bodypartExercises.removeAll()
        let node = firebase.childByAppendingPath("bodyparts/\(bodypart.key)/exercises")
        node.queryOrderedByValue().observeSingleEventOfType(.Value, withBlock: { result in
            let enumerator = result.children
            while let child = enumerator.nextObject() as? FDataSnapshot {
                //println(child.key)
                //println(child.value)
                //fetch the exercise name from the global exercise list....
                let exerciseDisplayName = self.allExercises.filter { $0.key == child.key }[0].name
                self.bodypartExercises += [(key: child.key!, name: exerciseDisplayName)]
                println(self.bodypartExercises)
            }
            self.collectionView?.reloadData()
        })
    }
    
    //long press will delete an exercise associated with the bodypart
    func handleLongPress(recognizer : UILongPressGestureRecognizer) {
        if recognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        let p = recognizer.locationInView(self.collectionView!)
        if let indexPath = collectionView!.indexPathForItemAtPoint(p) {
            let cell = collectionView!.cellForItemAtIndexPath(indexPath) as! ExerciseCell
            removeExercise(cell.title.text!, indexPath:indexPath)
        }
        else {
            println("could not find cell for longpress")
        }
    }

 
    
    func handleSwipeLeft(recognizer : UISwipeGestureRecognizer) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    
    func addTitleBar() {
        self.navigationItem.title = bodypart.name
    }
    
    //this will let the user choose an exercise from the global list of exercises which has not already been chosen for this bodypart
    func pickExercise() {
        exercisesValidForSelection.removeAll()
        let bpKeys = bodypartExercises.map { $0.key }
        //filter out any of the exercises that are already chosen
        var x = allExercises.filter { find(bpKeys, $0.key) == nil }
        //display them alphabetically
        x.sort { $0.key < $1.key }
        exercisesValidForSelection = x
        //recognize a tap outside the picker closes it down
        self.collectionView?.addGestureRecognizer(tapGesture)
        self.pickerHiddenTextField.becomeFirstResponder()
    }
    
    func removeExercise(title : String, indexPath : NSIndexPath) {
        var alert = UIAlertController(title: "",
            message: "Do you want to remove \(title) from \(bodypart.name)?",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Remove",
            style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction!) in
                let key = self.bodypartExercises[indexPath.row].key
                let node = self.firebase.childByAppendingPath("bodyparts/\(self.bodypart.key)/exercises/\(key)")
                node.removeValueWithCompletionBlock {(result) in
                    //println(result)
                    self.fetchBodypart()
                }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
            style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }

    
    
    func exitPicker() {
        pickerHiddenTextField.resignFirstResponder()
        self.collectionView?.removeGestureRecognizer(tapGesture)
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
        return bodypartExercises.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ExerciseCell
        cell.title.text = bodypartExercises[indexPath.row].name
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
    
    // MARK:  UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.exercisesValidForSelection.count + 1
    }
    
    //MARK: Delegates
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var color = row == indexOfAddNewExercise ? UIColor.redColor() : UIColor.blackColor()
        var title = row == indexOfAddNewExercise ? "[Add new exercise]" : exercisesValidForSelection[row].name
        
        var attributedString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName : color])
        
        return attributedString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == indexOfAddNewExercise {
            addNewExercise()
        }
        else {
            let exercise = exercisesValidForSelection[row]
            addExerciseToBodypart(bodypart.key, exerciseKey: exercise.key)
        }
    }
    
    func addExerciseToBodypart(bodypartKey : String, exerciseKey : String) {
        let childKey = firebase.childByAppendingPath("bodyparts/\(bodypartKey)/exercises/\(exerciseKey)")
        //put it at the end (which would be the index = total exercises already picked
        childKey.setValue(bodypartExercises.count, withCompletionBlock: { _ in
            self.pickerHiddenTextField.resignFirstResponder()
            self.fetchBodypart()
            self.saveExerciseBodypartRelationship(exerciseKey, bodypartKey: bodypartKey)
        })
    }
    
    func saveExerciseBodypartRelationship(exerciseKey : String,  bodypartKey : String) {
        let childKey = firebase.childByAppendingPath("bodyparts/\(bodypartKey)/exercises/\(exerciseKey)")
        //put it at the end (which would be the index = total exercises already picked
        childKey.setValue(bodypartExercises.count, withCompletionBlock: { _ in
            self.pickerHiddenTextField.resignFirstResponder()
            //trigger a refetch
            self.fetchBodypart()
        })
    }
    
    func addNewExercise() {
        var alert = UIAlertController(title: "Exercise",
            message: "Add a new exercise",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "Exercise"
        }
        
        alert.addAction(UIAlertAction(title: "Save",
            style: .Default, handler: { (action: UIAlertAction!) in
                let name = (alert.textFields![0] as! UITextField).text
                let key = name.removeWhitespace().lowercaseString
                let keys = self.allExercises.map { $0.key }
                if  find(keys,key) == nil {
                    //first add it to the global list of exercises
                    var dict = [String:AnyObject]()
                    dict["isSystem"] = false
                    dict["name"] = name
                    let node = self.firebase.childByAppendingPath("exercises/\(key)")
                    node.setValue(dict, withCompletionBlock: { (error,result) in
                        println(result)
                        self.fetchGlobalExercises()
                        self.saveExerciseBodypartRelationship(key, bodypartKey: self.bodypart.key)
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
    
    
    

}
