//
//  InputViewController.swift
//  SoftLocal
//
//  Created by Kyle Williamson on 25/02/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var type:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("input_title", comment : "Title Label")
        var submitBtn = NSLocalizedString("input_btn", comment : "Submit Button")
        
        self.submitBtn.setTitle(submitBtn, forState:UIControlState.Normal)
        
        if(type == "imperial") {
            imperialView()
        } else if(type == "metric") {
            metricView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imperialView() {
        heightLabel.text = NSLocalizedString("height_title_imp", comment : "Imperial Height Label")
        weightLabel.text = NSLocalizedString("weight_title_imp", comment : "Imperial Weight Label")
    }
    
    func metricView() {
        heightLabel.text = NSLocalizedString("height_title_met", comment : "Metric Height Label")
        weightLabel.text = NSLocalizedString("weight_title_met", comment : "Metric Height Label")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var validCount =  0
        
        if let n = heightTextField.text.toInt() {
            validCount++
        }
        
        if let n = weightTextField.text.toInt() {
            validCount++
        }
        
        if(validCount == 2) {
            let vc = segue.destinationViewController as OutputViewController
            vc.type = type
            vc.height = heightTextField.text.toInt()!
            vc.weight = weightTextField.text.toInt()!
        } else {
            var alert: UIAlertView = UIAlertView()
            alert.title = "Error"
            alert.message = "All fields must completed. Whole numbers only."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
}
