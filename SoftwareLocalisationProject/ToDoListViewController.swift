//
//  ToDoListViewController.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 27/03/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddMenuViewControllerDelegate, ItemDataViewControllerDelegate, SynchroniseControllerProtocol {
    
    
    //MARK -Outlets and Properties
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var synchroniseBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    let kCellIdentifier:String = "TodoCell"
    var list = [NSManagedObject]()
    var synchronise = SynchroniseController()
    
    
    //MARK -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.synchronise.delegate = self
        localizeStrings()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    //MARK -Delegates and DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        cell.textLabel!.text = list[indexPath.row].valueForKey("title") as? String
        
        //Changes cell textlabel allignment to RTL if Layout Direction is RTL
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.RightToLeft {
            cell.textLabel?.textAlignment = NSTextAlignment.Right
        }
        
        return cell
    }
    
    //Function that adds delete style to each table row
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let itemToDelete = list[indexPath.row]
            list.removeAtIndex(indexPath.row)
            managedObjectContext?.deleteObject(itemToDelete)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func addDidFinish(controller: AddMenuViewController) {
        controller.navigationController!.popViewControllerAnimated(true)
    }
    
    func itemDataDidFinish(controller: ItemDataViewController) {
        controller.navigationController!.popViewControllerAnimated(true)
    }
    
    func didReceiveSync(url: NSString) {
        synchronise.sendNotification(url)
    }
    
    //MARK -Instance Functions
    
    //Function that localizes strings that appear in this view
    func localizeStrings() {
        var title = NSLocalizedString("ToDoList_title", comment :"Title Label text")
        titleLabel.text = title;
        
        var add = NSLocalizedString("label_add", comment :"Add Button text")
        addBtn.setTitle(add, forState: UIControlState.Normal)
        
        var sync = NSLocalizedString("ToDoList_synchronise", comment :"Add Button text")
        synchroniseBtn.setTitle(sync, forState: UIControlState.Normal)
    }
    
    //Function that retrieves data from CoreData
    func fetchData() {
        
        let fetchNoteRequest = NSFetchRequest(entityName: "SimpleNote")
        
        let fetchListRequest = NSFetchRequest(entityName: "List")
        
        var error: NSError?
        
        let fetchedNoteResults = managedObjectContext!.executeFetchRequest(fetchNoteRequest, error: &error) as [NSManagedObject]?
        
        let fetchedListResults = managedObjectContext!.executeFetchRequest(fetchListRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedNoteResults {
            list = results
        }
        
        if let results = fetchedListResults {
            let newList = list + results
            list = newList
        }
        
        self.tableView.reloadData()
    }
    
    //Function that executes before a Storyboard Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "addSegue" {
            let vc = segue.destinationViewController as AddMenuViewController
            vc.delegate = self
        } else if segue.identifier == "itemDataSegue" {
            //Passes data of selected table row to next view
            let vc = segue.destinationViewController as ItemDataViewController
            let index = tableView.indexPathForSelectedRow()?.row
            vc.data = list[index!]
            vc.delegate = self
        }
    }
    
    
    @IBAction func sync(sender: AnyObject) {
        var jsonObject : [AnyObject] = []
        
        for item in list {
            var type = item.entity.name!
            var typeNo = 0;
            
            if type == "SimpleNote" {
                var obj : AnyObject = generateNoteDict(item)
                jsonObject.append(obj)
            } else if type == "List" {
                var obj : AnyObject = generateListDict(item)
                jsonObject.append(obj)
            }
        }
        var params = synchronise.JSONStringify(jsonObject)
        params = "data=" + params
        synchronise.conn(params)
    }
    
    func generateNoteDict(item : NSManagedObject) -> AnyObject {
        var name = item.valueForKey("title") as? String
        var content = item.valueForKey("content") as? String
        var object = ["type": 0, "list" : [], "note" : content!, "name" : name!]
        
        return object
    }
    
    func generateListDict(item : NSManagedObject) -> AnyObject {
        var name = item.valueForKey("title") as? String
        var listItems : NSOrderedSet = item.valueForKey("relationship") as NSOrderedSet
        var items : [AnyObject] = []
        for var i = 0; i<listItems.count; i++ {
            var current = listItems.objectAtIndex(i) as NSManagedObject
            var text = current.valueForKey("text") as String
            var completed = current.valueForKey("complete") as? NSNumber
            var item = ["sel" : completed!, "txt" : text]
            items.append(item)
        }
        
        var object = ["type" : 1, "list" : items, "name" : name!]
        
        return object
    }
}

