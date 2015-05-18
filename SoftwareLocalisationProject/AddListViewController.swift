//
//  AddListViewController.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 28/03/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit
import CoreData

protocol AddListViewControllerDelegate {
    func addListDidFinish(controller:AddListViewController)
}

class AddListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK -Outlets and Properties
    var delegate:AddListViewControllerDelegate? = nil
    var type: String = ""
    var data: NSManagedObject? = nil
    let kCellIdentifier:String = "ListCell"
    var listItems = Array<String>()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    @IBOutlet weak var titleFieldLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var subtextLabel: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var alertField: UITextField!
    
    //MARK -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        subtextLabel.editable = false
        tableView.hidden = true
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
    //MARK -Delegates and DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        cell.textLabel?.text = listItems[indexPath.row]
        
        //Changes Textfield text alignment if Layout Direction is RTL
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.RightToLeft {
            cell.textLabel?.textAlignment = NSTextAlignment.Right
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            listItems.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            if type == "edit" {
                deleteListItem(indexPath.row)
            }
            if listItems.count == 0 {
                subtextLabel.hidden = false
                tableView.hidden = true
            }
        }
    }
    
    
    //MARK -Instance Functions
    
    //Function that localizes strings that appear in this view
    func localizeStrings() {
        var titleField = NSLocalizedString("label_title", comment: "Title field label text")
        var contentLabelText = NSLocalizedString("label_content", comment: "Content label text")
        var subtext = NSLocalizedString("AddList_subtext", comment: "Content subtext text")
        var addBtnText = NSLocalizedString("label_addItem", comment: "Add Item Button text")
        var okBtnText = NSLocalizedString("button_ok", comment: "Ok button text")
        
        titleFieldLabel.text = titleField
        contentLabel.text = contentLabelText
        subtextLabel.text = subtext + addBtnText
        addBtn.setTitle(addBtnText, forState: UIControlState.Normal)
        okBtn.setTitle(okBtnText, forState: UIControlState.Normal)
    }
    
    //Listener for Add Item button that shows a localised text field alert
    @IBAction func addItemListener(sender: AnyObject) {
        
        var okBtnText = NSLocalizedString("button_ok", comment: "Ok button text")
        var cancelBtnText = NSLocalizedString("label_cancel", comment: "Ok button text")
        var title = NSLocalizedString("label_addItem", comment: "Ok button text")
        var alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: okBtnText, style: UIAlertActionStyle.Default, handler: textEntered))
        alert.addAction(UIAlertAction(title: cancelBtnText, style: UIAlertActionStyle.Default, handler: nil))
        alert.addTextFieldWithConfigurationHandler(addTextField)
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    //Function that sets instance variable alertField to new textfield associated with addItem alert
    func addTextField(textField: UITextField!) {
        textField.placeholder = ""
        self.alertField = textField
    }
    
    //Function that responds to Add Item alert action
    func textEntered(alert: UIAlertAction!) {
        if self.alertField.text != "" {
            if listItems.count == 0 {
                subtextLabel.hidden = true
                tableView.hidden = false
            }
            listItems.append(self.alertField.text)
            if type == "edit" {
                let newListItem = NSEntityDescription.insertNewObjectForEntityForName("ListItem", inManagedObjectContext: self.managedObjectContext!) as ListItem
                newListItem.text = self.alertField.text
                newListItem.complete = false
                newListItem.relationship = data! as List
            }
            self.tableView.reloadData()
        } else {
            invalidInput()
        }
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
        if titleField.text == "" {
            invalidInput()
        } else {
            if type == "add" {
                save()
            } else if type == "edit" {
                edit()
            }
            if delegate != nil {
                delegate!.addListDidFinish(self)
            }
        }
    }
    
    //Function that initalizes UI fields if editing and existing note
    func initUIFields() {
        titleField.text = data!.valueForKey("title") as? String
        datePicker.date = data!.valueForKey("date") as NSDate
        generateList()
    }
    
    //Function that adds all List Items for the selected List into the variable list items
    func generateList() {
        var listItems = data!.valueForKey("relationship") as NSOrderedSet
        for var index = 0; index < listItems.count; ++index {
            var current = listItems.objectAtIndex(index) as NSManagedObject
            self.listItems.append(current.valueForKey("text") as String)
        }
        subtextLabel.hidden = true
        tableView.hidden = false
        self.tableView.reloadData()
    }
    
    //Function that deletes a list item from a List
    func deleteListItem(index : Int) {
        var listItems = data!.valueForKey("relationship") as NSOrderedSet
        let itemToDelete = listItems.objectAtIndex(index) as NSManagedObject
        managedObjectContext?.deleteObject(itemToDelete)
    }
    
    //Function that creates a new List and saves it to CoreData
    func save() {
        let newList = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.managedObjectContext!) as List
        
        newList.title = titleField.text
        newList.date = datePicker.date
        
        for item in listItems {
            let newListItem = NSEntityDescription.insertNewObjectForEntityForName("ListItem", inManagedObjectContext: self.managedObjectContext!) as ListItem
            newListItem.text = item
            newListItem.complete = false
            newListItem.relationship = newList
        }
    }
    
    //Function that edits data for selected List
    func edit() {
        data!.setValue(titleField.text, forKey: "title")
        data!.setValue(datePicker.date, forKey: "date")
    }
}
