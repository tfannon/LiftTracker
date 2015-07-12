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
    
    let onesValues = [0, 2.5, 5]
    
    let firebase = AppDelegate.get.firebase
    var firebasePr : Firebase!

    
    //will be set by preceeding view controller
    var exercise : (key:String, name:String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
        lblExercise.text = exercise.name
        firebasePr = firebase.childByAppendingPath("/exercises/\(exercise.key)/prs")
        fetchPR(10)
        //go fetch 10 rep max and display it
    }
    
    func fetchPR(rep : Int) {
        let node = firebasePr.childByAppendingPath("\(rep)")

        node.queryOrderedByValue().observeSingleEventOfType(.Value, withBlock: { result in
            if result.value is NSNull {
                self.lblCurrentPr.text = "No PR yet for \(rep) reps"
                //move to rep picker to the appropriate selection
                //set all weight values to 0
                self.picker.selectRow(rep-1, inComponent: 0, animated: true)
                self.picker.selectRow(0, inComponent: 1, animated: true)
                self.picker.selectRow(0, inComponent: 2, animated: true)
                self.picker.selectRow(0, inComponent: 3, animated: true)
                self.lblPickedValue.text = ""
            }
            else {
                print(result.value)
                //lblPickedValue.text = String(rep)
            }
        })
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
    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
//        switch (component) {
//            case (0) : return "\(row+1)"
//            case (1) : return "\(row)"
//            case (2) : return "\(row)"
//            case (3) : return "\(ones[row])"
//            default : return ""
//        }
//    }
    
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
    }
    
    //MARK: - Write value into firebase
    func savePr() {
        let reps : Int = picker.selectedRowInComponent(0) + 1
        let hundreds = picker.selectedRowInComponent(1)
        let tens = picker.selectedRowInComponent(2)
        let ones = onesValues[picker.selectedRowInComponent(3)]
        let weight : Int = Int(hundreds * 100) + Int(tens * 10) + Int(ones)
        let date = (NSDate().toString(format: .ISO8601) as NSString).substringToIndex(10)
        let node = firebasePr.childByAppendingPath("/\(reps)/\(date)")
        node.setValue(weight, withCompletionBlock: { _ in
            print("success")
        })
    }
}