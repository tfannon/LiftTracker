//
//  SetRepController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 6/26/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

class SetRepController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var lblPickedValue: UILabel!
    @IBOutlet weak var lblExercise: UILabel!
    
    let ones = [2.5, 5]
    
    //will be set by preceeding view controller
    var exercise : (key:String, name:String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        lblExercise.text = exercise.name
    }
    
    //MARK: - PickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (component) {
            case (0) : return 20
            case (1) : return 9
            case (2) : return 9
            case (3) : return 2
            default :
                println(component)
                return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch (component) {
            case (0) : return "\(row + 1)"
            case (1) : return "\(row + 1)"
            case (2) : return "\(row + 1)"
            case (3) : return "\(ones[row])"
            default : return ""
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
        var reps = picker.selectedRowInComponent(0) + 1
        var hundreds = picker.selectedRowInComponent(1) + 1
        var tens = picker.selectedRowInComponent(2) + 1
        var onesVal = ones[picker.selectedRowInComponent(3)]
        lblPickedValue.text = "\(hundreds)\(tens)\(onesVal) x \(reps)"
    }
}