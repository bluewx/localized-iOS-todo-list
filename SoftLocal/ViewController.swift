//
//  ViewController.swift
//  SoftLocal
//
//  Created by Kyle Williamson on 11/02/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

//    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var imperialBtn: UIButton!
    
    @IBOutlet weak var metricBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var impBtn = NSLocalizedString("imperial_btn", comment :"Label for Imperial Btn")
        imperialBtn.setTitle(impBtn, forState: UIControlState.Normal)
        
        var metBtn = NSLocalizedString("metric_btn", comment : "Label for Metric Button")
        
        metricBtn.setTitle(metBtn, forState: UIControlState.Normal)
//        dateTimeLabel.text = dateFormatter.stringFromDate(NSDate())
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        let vc = segue.destinationViewController as InputViewController
        if segue.identifier == "imperialSegue"{
            vc.type = "imperial"
        } else if segue.identifier == "metricSegue"{
            vc.type = "metric"
        }
    }

//    var dateFormatter: NSDateFormatter {
//        let formatter = NSDateFormatter()
//        
//        formatter.dateStyle = .MediumStyle
//        formatter.timeStyle = .MediumStyle
//        
//        return formatter
//    }

}

