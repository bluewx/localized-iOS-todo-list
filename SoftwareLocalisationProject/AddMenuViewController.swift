//
//  AddMenuViewController.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 28/03/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit

protocol AddMenuViewControllerDelegate {
    func addDidFinish(controller: AddMenuViewController)
}

class AddMenuViewController: UIViewController, AddListViewControllerDelegate, AddNoteViewControllerDelegate {

    
    //MARK -Outlets and Properties
    var delegate: AddMenuViewControllerDelegate? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtextLabel: UITextView!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var noteBtn: UIButton!
    
    //MARK -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        subtextLabel.editable = false
        localizeStrings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK -Delegates and DataSource
    func addNoteDidFinish(controller: AddNoteViewController) {
        controller.navigationController!.popViewControllerAnimated(true)
        if delegate != nil {
            delegate!.addDidFinish(self)
        }
    }
    
    func addListDidFinish(controller: AddListViewController) {
        controller.navigationController!.popViewControllerAnimated(true)
        if delegate != nil {
            delegate!.addDidFinish(self)
        }
    }
    
    //MARK -Instance Function
    
    //Function that localizes strings that appear in this view
    func localizeStrings() {
        var title = NSLocalizedString("label_addItem", comment: "AddMenu View Title")
        
        var subtext = NSLocalizedString("AddMenu_subtext", comment: "AddMenu subtext")
        var simpleNote = NSLocalizedString("AddNote_title", comment: "Add Simple Note selection")
        
        var list = NSLocalizedString("AddList_title", comment: "Add List selection")
        
        titleLabel.text = title
        subtextLabel.text = subtext
        noteBtn.setTitle(simpleNote, forState: UIControlState.Normal)
        listBtn.setTitle(list, forState: UIControlState.Normal)
    }
    
    //Function that executes before a Storyboard Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "addNoteSegue" {
            let vc = segue.destinationViewController as AddNoteViewController
            vc.type = "add"
            vc.delegate = self
        } else if segue.identifier == "addListSegue" {
            let vc = segue.destinationViewController as AddListViewController
            vc.type = "add"
            vc.delegate = self
        }
    }

}