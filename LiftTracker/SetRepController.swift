//
//  SetRepController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/26/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

enum PickMode {
    case Reps
    case Date
}


class SetRepController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MARK: outlets
    @IBOutlet weak var lblExercise: UILabel!
    @IBOutlet weak var lblCurrentPr: UILabel!
    @IBOutlet weak var lblPickedValue: UILabel!
    @IBOutlet weak var repsPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnDate: UIButton!
    
    
    //MARK: actions
    @IBAction func handleSaveTapped(sender: AnyObject) { self.savePr() }
    @IBAction func handleClearTapped(sender: AnyObject) { self.clearPr() }
    @IBAction func handleDateTapped(sender: AnyObject) { self.dateButtonTapped() }
    @IBAction func handleDateChanged(sender: AnyObject) { self.onDateChanged() }
    
    //MARK: class vars
    
    let onesValues = [0, 2.5, 5]
    
    let firebase = AppDelegate.get.firebase
    var firebasePr : Firebase!
    var prs = [Int:[String:Double]]()
    var currentPrInPicker : (reps : Int, date : String)?
    
    var pickerMode = PickMode.Reps
    
    //will be set by preceeding view controller
    var exercise : (key:String, name:String)!

    //MARK: view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repsPicker.dataSource = self
        repsPicker.delegate = self
        lblExercise.text = exercise.name
        firebasePr = firebase.childByAppendingPath("/exercises/\(exercise.key)/prs")
        
        FirebaseHelper.getPrs(firebase, exercise: exercise.key) { (result) in
            self.prs = result
            //go fetch 10 rep max and display it
            self.setPickersWithPrForRep(10)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewTapped"))
        
        //datePicker.setValue(UIColor.whiteColor(), forKeyPath:"textColor")
    }
    
    func viewTapped() {
        if pickerMode == .Date {
            println("View tapped while user was in date pick mode")
            switchPickerMode()
        }
    }
    
    
    
    func setPickersWithPrForRep(rep : Int) {
        let (date, weight) = getLargestWeight(rep)
        if weight > 0 {
            lblCurrentPr.text = "PR: \(weight) x \(rep) on \(date.toDate().toShortString())"
            currentPrInPicker = (rep, date)
            setRepsAndWeight(rep, weight: weight, date: date)
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
        setRepsAndWeight(rep, weight: 0.0, date: nil)
    }
    
    func setRepsAndWeight(reps : Int, weight : Double, date : String?) {
        let hundreds  = Int(weight / 100)
        let tens = Int((weight - (Double(hundreds) * 100)) / 10)
        let ones = Double(weight - (Double(hundreds) * 100) - (Double(tens) * 10))
        repsPicker.selectRow(reps-1, inComponent: 0, animated: true)
        repsPicker.selectRow(hundreds, inComponent: 1, animated: true)
        repsPicker.selectRow(tens, inComponent: 2, animated: true)
        repsPicker.selectRow(find(self.onesValues, ones)!, inComponent: 3, animated: true)
        let picked = "\(hundreds)\(tens)\(ones)"
        if weight > 0 {
            lblPickedValue.text = "\(picked) x \(reps)"
            //datePicker.setDate(NSDate(isoString: date!), animated: true)
            datePicker.setDate(date!.toDate(), animated: true)
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
        //if reps were changed, go get the current PR
        if component == 0 {
            setPickersWithPrForRep(self.reps)
        }
        //otherwise update the picked value
        else {
            displayPickedValue()
        }
    }
    
    func displayPickedValue() {
        let picked = getPickedValues()
        lblPickedValue.text = "\(picked.weight) x \(picked.reps)"
        if !picked.date.isToday() {
            lblPickedValue.text = lblPickedValue.text! + " on \(picked.date.toShortString())"
        }
    }
    
    func getPickedValues() -> (reps: Int, weight: Double, date: NSDate) {
        let hundreds = repsPicker.selectedRowInComponent(1)
        let tens = repsPicker.selectedRowInComponent(2)
        let ones = onesValues[repsPicker.selectedRowInComponent(3)]
        let date = datePicker.date
        let weight = (Double(hundreds) * 100) + (Double(tens) * 10) + ones
        return (self.reps, weight, date)
    }
    
    //MARK: - Write value into firebase
    func savePr() {
        let reps : Int = repsPicker.selectedRowInComponent(0) + 1
        let hundreds = repsPicker.selectedRowInComponent(1)
        let tens = repsPicker.selectedRowInComponent(2)
        let ones = onesValues[repsPicker.selectedRowInComponent(3)]
        let weight : Double = (Double(hundreds) * 100) + (Double(tens) * 10) + ones
        //make sure this is actually a PR
        let (_,currentPR) = getLargestWeight(reps)
        if weight > currentPR {
            let date = NSDate().toIsoString()
            let node = firebasePr.childByAppendingPath("/\(reps)/\(date)")
            node.setValue(weight, withCompletionBlock: { _ in
                self.lblCurrentPr.text = "\(weight) x \(reps) on \(date)"
                self.currentPrInPicker = (reps, date)
                if self.prs[reps] == nil {
                    self.prs[reps] = [String:Double]()
                }
                self.prs[reps]![date] = weight
                println("saved \(weight)x\(reps) on \(date)")
            })
        }
        //todo: throw alert box
    }
    
    var reps : Int {
        get {
            return repsPicker.selectedRowInComponent(0) + 1
        }
    }
    
    func clearPr() {
        if let pr = currentPrInPicker {
            let prToClear = firebase.childByAppendingPath("/exercises/\(exercise.key)/prs/\(pr.reps)/\(pr.date)")
            prToClear.removeValueWithCompletionBlock( { (result) in
                println("cleared \(prToClear.description)")
                //update our in place dictionary
                self.prs[pr.reps]!.removeValueForKey(pr.date)
                //go lookup the new pr
                self.setPickersWithPrForRep(pr.reps)
            })
        }
    }
    
    //MARK: date button
    func dateButtonTapped() {
        switchPickerMode()
    }
    
    func switchPickerMode() {
        if pickerMode == .Reps {
            repsPicker.hidden = true
            datePicker.hidden = false
            //println(datePicker.date.toIsoString())
            btnDate.setTitle("Reps", forState: .Normal)
            pickerMode = .Date
        } else {
            repsPicker.hidden = false
            datePicker.hidden = true
            btnDate.setTitle("Date", forState: .Normal)
            pickerMode = .Reps
        }
    }
    
    //MARK: date picker
    func onDateChanged() {
        displayPickedValue()
        switchPickerMode()
    }
}