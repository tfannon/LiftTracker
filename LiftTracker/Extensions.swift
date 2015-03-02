//
//  Extensions.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 3/2/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//
import UIKit

extension UIViewController {

    func addButton(title : String, action : Selector, color : UIColor? = nil) -> UIButton {
        let button = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 88, UIScreen.mainScreen().bounds.size.width, 44))
        button.setTitle(title, forState: .Normal)
        button.backgroundColor = color ?? UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        return button
    }
}

