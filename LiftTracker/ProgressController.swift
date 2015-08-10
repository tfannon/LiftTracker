//
//  ProgressController.swift
//  LiftTracker
//
//  Created by Tommy Fannon on 7/26/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

class ProgressController: UIViewController, JBBarChartViewDataSource, JBBarChartViewDelegate {
    
    var chartLegend = [String]()
    var chartData = [Float]()
    var chartBars = [BarView]()
    
    let barChartView = JBBarChartView()
    let footerView = FooterView()
    let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    let headerHeight:CGFloat = 80
    let footerHeight:CGFloat = 40
    let padding:CGFloat = 10
    
    
    override func viewDidLoad() {
        barChartView.dataSource = self;
        barChartView.delegate = self;
        barChartView.backgroundColor = UIColor.darkGrayColor();
        barChartView.frame = CGRectMake(0, 20, self.view.bounds.width, self.view.bounds.height * 0.5);
        barChartView.minimumValue = 0
        self.view.addSubview(barChartView);
        
        // Header
        headerView.frame = CGRectMake(padding,ceil(self.view.bounds.size.height * 0.5) - ceil(headerHeight * 0.5),self.view.bounds.width - padding*2, headerHeight)
        //headerView.titleLabel.text = "Loading..."
        headerView.subtitleLabel.text = "Max Weight per Rep"
        barChartView.headerView = headerView
        
        // Footer
        footerView.frame = CGRectMake(padding, ceil(self.view.bounds.size.height * 0.5) - ceil(footerHeight * 0.5),self.view.bounds.width - padding*2, footerHeight)
        footerView.padding = padding
        footerView.leftLabel.textColor = UIColor.whiteColor()
        footerView.rightLabel.textColor = UIColor.whiteColor()
        barChartView.footerView = footerView
        
        downloadLiftData()
    }
    
    func downloadData() {
        var results = []
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        
        let json = JSON(url:"http://api.openweathermap.org/data/2.5/forecast/daily?q=atlanta&mode=json&units=metric&cnt=10")
        if let days = json["list"].asArray {
            var i:Int = 0 ;
            for day in days {
                println("day")
                var temperature:Double = day["temp"]["day"].asDouble!;
                println(temperature)
                var date:Double = day["dt"].asDouble!;
                
                chartLegend.append(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: date)))
                chartData.append(Float(temperature))
                chartBars.append(BarView(frame: CGRectZero, footer: footerView))
            }
            headerView.titleLabel.text = json["city"]["name"].asString
            barChartView.reloadData();
            barChartView.setState(JBChartViewState.Expanded, animated: true)
        }
    }
    
    func downloadLiftData() {
        var results = []
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        
        var fbTestRoot = Firebase(url:"https://lifttracker2.firebaseio.com/test")
        var fbTestUser : Firebase { get { return fbTestRoot.childByAppendingPath("JoeStrong2") }}
        
        FirebaseHelper.getPrs(fbTestUser, exercise: "benchpress", completion: { (result:[Int:[String:Double]]) in
            //println(result)
            let sortedKeys = result.keys.array.sorted { $0<$1 }
            println(sortedKeys)
            for rep in sortedKeys {
                if let pr = FirebaseHelper.getPrForRep(result, rep: rep) {
                    println(pr)
                    self.chartLegend.append(String(rep))
                    self.chartData.append(Float(pr.weight))
                    self.chartBars.append(BarView(frame: CGRectZero, footer: self.footerView))
                }
            }
            self.barChartView.reloadData();
            self.barChartView.setState(JBChartViewState.Expanded, animated: true)
        })
    }
    
    
    
    /* Returns the numbers of BARs */
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(chartData.count)
    }
    
    /* Returns the value @ index */
    func barChartView(barChartView: JBBarChartView, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return CGFloat(chartData[Int(index)])
    }
    
    /* Returns bar @ index */
    func barChartView(barChartView: JBBarChartView!, barViewAtIndex index: UInt) -> UIView! {

        var barView = chartBars[Int(index)]
        barView.backgroundColor = (Int(index) % 2 == 0 ) ? uicolorFromHex(0x34b234) : uicolorFromHex(0x08bcef)
        barView.legendLabel.text = chartLegend[Int(index)]
        barView.valueLabel.text = String(stringInterpolationSegment: chartData[Int(index)])
        println("\(barView.valueLabel.text!) \(barView.legendLabel.text!)")
        return barView
    }
    
    /*
    Converts hex values to UIColor(with red, green and blue)
    */
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
