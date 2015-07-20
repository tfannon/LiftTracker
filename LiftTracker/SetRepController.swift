//
//  SetRepController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/26/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

class SetRepController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var lblExercise: UILabel!
    @IBOutlet weak var lblCurrentPr: UILabel!
    @IBOutlet weak var lblPickedValue: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBAction func handleSaveTapped(sender: AnyObject) {
        self.savePr()
    }
    
    @IBAction func handleClearTapped(sender: AnyObject) {
        self.clearPr()
    }
    
    let onesValues = [0, 2.5, 5]
    
    let firebase = AppDelegate.get.firebase
    var firebasePr : Firebase!
    var prs = [Int:[String:Double]]()
    var currentPrInPicker : (reps : Int, date : String)?
    
    
    //will be set by preceeding view controller
    var exercise : (key:String, name:String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
        lblExercise.text = exercise.name
        firebasePr = firebase.childByAppendingPath("/exercises/\(exercise.key)/prs")
        //let test = FirebaseHelper.getPrs(firebase, exercise: exercise.key)
        firebasePr.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { (result) in
            for x in result.children {
                let repSnap = x as! FDataSnapshot
                let rep = repSnap.key.toInt()!
                if self.prs[rep] == nil {
                    self.prs[rep] = [String:Double]()
                }
                var dateDict = [String:Double]()
                for y in repSnap.children {
                    let dateSnap = y as! FDataSnapshot
                    dateDict[dateSnap.key] = dateSnap.value as? Double
                    self.prs[rep] = dateDict
                }
            }
            //go fetch 10 rep max and display it
            self.setPickerWithRep(10)
        })
    }
    
    
    func setPickerWithRep(rep : Int) {
        let (date, weight) = getLargestWeight(rep)
        if weight > 0 {
            self.lblCurrentPr.text = "\(weight) x \(rep) on \(date)"
            self.currentPrInPicker = (rep, date)
            setRepsAndWeight(rep, weight: weight)
        }
        else {
            movePickerToZero(rep)
        }
    }
    
    func getLargestWeight(rep : Int) -> (date : String, weight : Double) {
        if let node = prs[rep] {
            var largestDate : String = ""
            var largestWeight : Double = 0
            for (date,weight) in node {
                if weight > largestWeight {
                    largestWeight = weight
                    largestDate = date
                }
            }
            if largestWeight > 0 {
                return (largestDate, largestWeight)
            }
        }
        return ("",0)
    }
    
    
    func movePickerToZero(rep : Int) {
        self.lblCurrentPr.text = "No PR yet for \(rep) reps"
        self.lblPickedValue.text = ""
        setRepsAndWeight(rep, weight: 0)
    }
    
    func setRepsAndWeight(reps : Int, weight : Double) {
        let hundreds  = Int(weight / 100)
        let tens = Int((weight - (Double(hundreds) * 100)) / 10)
        let ones = Int(weight - (Double(hundreds) * 100) - (Double(tens) * 10))
        self.picker.selectRow(reps-1, inComponent: 0, animated: true)
        self.picker.selectRow(hundreds, inComponent: 1, animated: true)
        self.picker.selectRow(tens, inComponent: 2, animated: true)
        self.picker.selectRow(ones, inComponent: 3, animated: true)
        let picked = "\(hundreds)\(tens)\(ones)"
        if weight > 0 {
            lblPickedValue.text = "\(picked) x \(reps)"
        }
    }
    
    //MARK: - PickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (component) {
        case (0) : return 20
        case (1) : return 10
        case (2) : return 10
        case (3) : return 3
        default :
            print(component)
            return 0
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let color = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        switch (component) {
        case (0) : return NSAttributedString(string: "\(row+1)", attributes: color)
        case (1) : return NSAttributedString(string: "\(row)", attributes: color)
        case (2) : return NSAttributedString(string: "\(row)", attributes: color)
        case (3) : return NSAttributedString(string: "\(onesValues[row])", attributes: color)
        default : return nil
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 80
        } else if (component == 3) {
            return 45
        }
        else {
            return 22
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let reps = picker.selectedRowInComponent(0) + 1
        let hundreds = picker.selectedRowInComponent(1)
        let tens = picker.selectedRowInComponent(2)
        let ones = onesValues[picker.selectedRowInComponent(3)]
        var picked = ""
        //strip leading zeros
        if hundreds == 0 {
            if tens == 0 {
                picked = "\(ones)"
            } else {
                picked = "\(tens)\(ones)"
            }
        }
        else {
            picked = "\(hundreds)\(tens)\(ones)"
        }
        lblPickedValue.text = "\(picked) x \(reps)"
        //if reps were changed, go set the current PR
        if component == 0 {
            setPickerWithRep(reps)
        }
    }
    
    //MARK: - Write value into firebase
    func savePr() {
        let reps : Int = picker.selectedRowInComponent(0) + 1
        let hundreds = picker.selectedRowInComponent(1)
        let tens = picker.selectedRowInComponent(2)
        let ones = onesValues[picker.selectedRowInComponent(3)]
        let weight : Double = (Double(hundreds) * 100) + (Double(tens) * 10) + ones
        //make sure this is actually a PR
        let (_,currentPR) = getLargestWeight(reps)
        if weight > currentPR {
            let date = NSDate().toIsoNSString().substringToIndex(10)
            let node = firebasePr.childByAppendingPath("/\(reps)/\(date)")
            node.setValue(weight, withCompletionBlock: { _ in
                self.lblCurrentPr.text = "\(weight) x \(reps) on \(date)"
                self.currentPrInPicker = (reps, date)
                if self.prs[reps] == nil {
                    self.prs[reps] = [String:Double]()
                }
                self.prs[reps]![date] = weight
                print("success")
            })
        }
        //todo: throw alert box
    }
    
    var reps : Int {
        get {
            return picker.selectedRowInComponent(0) + 1
        }
    }
    
    func clearPr() {
        if let pr = currentPrInPicker {
            let prToClear = firebase.childByAppendingPath("/exercises/\(exercise.key)/prs/\(pr.reps)/\(pr.date)")
            prToClear.removeValueWithCompletionBlock( { (result) in
                //update our in place dictionary
                self.prs[pr.reps]!.removeValueForKey(pr.date)
                self.setPickerWithRep(pr.reps)
            })
        }
    }
    
    
}