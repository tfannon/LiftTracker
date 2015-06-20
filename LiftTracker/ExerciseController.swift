//
//  ExerciseController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 12/28/14.
//  Copyright (c) 2014 Crazy8Dev. All rights reserved.
//

import UIKit


class ExerciseController: UICollectionViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView(frame:self.view.bounds)
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imageView.image = UIImage(named: "dumbells.jpg")!
        self.view.insertSubview(imageView, atIndex: 0)
        
        addTitleBar()
        
        self.btnAddExercise = self.addButton("+", action: "addNewExercise")
        setupPickerView()
        
        //the long press will trigger a delete for now
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
        self.tapGesture = UITapGestureRecognizer(target: self, action: "handleTap")
     }
    
    func fetchGlobalExercises() {
        allExercises.removeAll()
        let node = firebase.childByAppendingPath("exercises")
        node.observeSingleEventOfType(.Value, withBlock: { result in
            //println(result)
            let enumerator = result.children
            while let child = enumerator.nextObject() as? FDataSnapshot {
                //println(child.value)
                let name = (child.value as! NSDictionary) ["name"] as! String
                self.allExercises += [(key: child.key!, name: name)]
            }
            //println(self.allExercises)
        })
    }
    
    func fetchBodypart() {
        bodypartExercises.removeAll()
        let node = firebase.childByAppendingPath("bodyparts/\(bodypart.key)/exercises")
        node.queryOrderedByChild("displayOrder").observeSingleEventOfType(.Value, withBlock: { result in
            let enumerator = result.children
            while let child = enumerator.nextObject() as? FDataSnapshot {
                //println(child.key)
                //println(child.value)
                //fetch the exercise name from the global exercise list....
                let exerciseDisplayName = self.allExercises.filter { $0.key == child.key }[0].name
                self.bodypartExercises += [(key: child.key!, name: exerciseDisplayName)]
                //println(self.bodypartExercises)
            }
            self.collectionView?.reloadData()
        })
    }
 
    
    func handleSwipeLeft(recognizer : UISwipeGestureRecognizer) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    
    func addTitleBar() {
        self.navigationItem.title = bodypart.name
    }
    
    func addNewExercise() {
        exercisesValidForSelection.removeAll()
        let bpKeys = bodypartExercises.map { $0.key }
        var x = allExercises.filter { find(bpKeys, $0.key) == nil }
        x.sort { $0.key < $1.key }
        //println(x)
        exercisesValidForSelection = x
        //recognize a tap outside the picker closes it down
        self.collectionView?.addGestureRecognizer(tapGesture)
        self.pickerHiddenTextField.becomeFirstResponder()
    }
    
    func handleTap() {
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
        return self.exercisesValidForSelection.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        return self.exercisesValidForSelection[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let exercise = exercisesValidForSelection[row]
        let childKey = firebase.childByAppendingPath("bodyparts/\(bodypart.key)/exercises/\(exercise.key)")
        childKey.setValue(bodypartExercises.count, withCompletionBlock: { _ in
            self.pickerHiddenTextField.resignFirstResponder()
            self.fetchBodypart()
        })
        
    }

}
