//
//  ItemDataViewController.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 30/03/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit
import CoreData
protocol ItemDataViewControllerDelegate {
    func itemDataDidFinish(controller: ItemDataViewController)
}

class ItemDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,AddNoteViewControllerDelegate, AddListViewControllerDelegate {
    
    //MARK -Outlets and Properites
    var delegate: ItemDataViewControllerDelegate? = nil
    let kCellIdentifier:String = "ListCell"
    var data: NSManagedObject? = nil
    var type: String = ""
    var listItems = NSOrderedSet()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!

    //MARK -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.editable = false
        localizeContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        type = data!.entity.name!
        titleLabel.text = data!.valueForKey("title") as? String
        if type == "SimpleNote" {
            simpleNoteView()
        } else if type == "List" {
            listView()
        }
    }
    
    //MARK -Delegates and DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        var current = listItems.objectAtIndex(indexPath.row) as NSManagedObject
        cell.textLabel!.text = current.valueForKey("text") as? String
        
        //Code for setting table cell to green if completed
        let completed = current.valueForKey("complete") as? NSNumber
        if completed! == 1 {
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.greenColor()
        } else {
            cell.textLabel!.textColor = UIColor.blackColor()
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        //Changes Textfield text alignment if Layout Direction is RTL
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.RightToLeft {
            cell.textLabel?.textAlignment = NSTextAlignment.Right
        }
        
        return cell
    }
    
    //Function that changes list items status if row is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)
        var current = listItems.objectAtIndex(indexPath.row) as NSManagedObject
        let complete = current.valueForKey("complete") as NSNumber
        if complete == 0 {
            current.setValue(1, forKey: "complete")
        } else {
            current.setValue(0, forKey: "complete")
        }
        tableView.reloadData()
    }
    
    func addListDidFinish(controller: AddListViewController) {
        controller.navigationController!.popViewControllerAnimated(true)
    }
    func addNoteDidFinish(controller: AddNoteViewController) {
        controller.navigationController!.popViewControllerAnimated(true)
    }
    
    //MARK -Instance Functions
    
    //Function that localizes strings that appear in this view
    func localizeContent() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        var editText = NSLocalizedString("label_edit", comment: "Edit Button Text")
        editBtn.setTitle(editText, forState: UIControlState.Normal)
        
        dateLabel.text = formatter.stringFromDate(data!.valueForKey("date") as NSDate)
    }
    
    //Function that sets up the view for displaying note data
    func simpleNoteView() {
        tableView.hidden = true
        textView.editable = false
        textView.text = data!.valueForKey("content") as? String
    }
    
    //Function that sets up the view for displaying list data
    func listView() {
        textView.hidden = true
        listItems = data!.valueForKey("relationship") as NSOrderedSet
    }
    
    //Function that navigates to AddNoteViewController with Note Data
    func switchScreenNote() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : AddNoteViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AddNoteViewController") as AddNoteViewController
        vc.type = "edit"
        vc.data = data
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //Function that navigates to AddListViewController with List Data
    func switchScreenList() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : AddListViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AddListViewController") as AddListViewController
        vc.type = "edit"
        vc.data = data
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //Listener to Edit Button that calls required navigation function
    @IBAction func editAction(sender: AnyObject) {
        if type == "SimpleNote" {
            switchScreenNote()
        } else if type ==  "List" {
            switchScreenList()
        }
    }
}
