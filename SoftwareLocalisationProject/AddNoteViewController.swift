//
//  AddNoteViewControlelr.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 28/03/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit
import CoreData

protocol AddNoteViewControllerDelegate {
    func addNoteDidFinish(controller: AddNoteViewController)
}

class AddNoteViewController: UIViewController {
    
    //MARK -Outlets and Properties
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var delegate:AddNoteViewControllerDelegate? = nil
    var type: String = ""
    var data: NSManagedObject? = nil
    
    @IBOutlet weak var titleFieldLabel: UILabel!
    @IBOutlet weak var contentField: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var okBtn: UIButton!
    
    //MARK -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.grayColor().CGColor
        if type == "edit" {
            initUIFields()
        }
        
        //Changes Textfield text alignment if Layout Direction is RTL
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.RightToLeft {
             titleField.textAlignment = NSTextAlignment.Right
        }
        
        localizeStrings()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK -Instance Functions
    
    //Function that localizes strings that appear in this view
    func localizeStrings() {
        
        var titleField = NSLocalizedString("label_title", comment: "TitleField Label text")
        
        var content = NSLocalizedString("label_content", comment: "Content Label text")
        
        var okBtnText = NSLocalizedString("button_ok", comment: "Button Label Okay")
        
        titleFieldLabel.text = titleField
        contentField.text = content
        okBtn.setTitle(okBtnText, forState: UIControlState.Normal)
        
    }
    
    //Function that shows a localized alert if invalid input given
    func invalidInput() {
        var okBtnText = NSLocalizedString("button_ok", comment: "Ok button text")
        var errorTitle = NSLocalizedString("label_errorTitle", comment: "Error Title")
        var errorMessage = NSLocalizedString("label_errorMessage", comment: "Error Message")
        
        var alert: UIAlertView = UIAlertView()
        alert.title = errorTitle
        alert.message = errorMessage
        alert.addButtonWithTitle(okBtnText)
        alert.show()
    }
    
    //Listener for okay button that saves/updates data
    @IBAction func okayAction(sender: AnyObject) {
        if titleField.text == "" || textView.text == "" {
            invalidInput()
        } else {
            if type == "add" {
                save()
            } else if type == "edit" {
                edit()
            }
            if delegate != nil {
                delegate!.addNoteDidFinish(self)
            }
        }
    }
    
    //Function that updates data for the selected note
    func edit() {
        data!.setValue(titleField.text, forKey: "title")
        data!.setValue(textView.text, forKey: "content")
        data!.setValue(datePicker.date, forKey: "date")
    }
    
    //Function that creates a new note
    func save() {
        let newNote = NSEntityDescription.insertNewObjectForEntityForName("SimpleNote", inManagedObjectContext: self.managedObjectContext!) as SimpleNote
        
        newNote.title = titleField.text
        newNote.content = textView.text
        newNote.date = datePicker.date
    }
    
    //Function that initalizes UI fields if editing and existing note
    func initUIFields() {
        titleField.text = data!.valueForKey("title") as? String
        textView.text = data!.valueForKey("content") as? String
        datePicker.date = data!.valueForKey("date") as NSDate
    }
}
