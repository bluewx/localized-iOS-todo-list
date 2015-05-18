//
//  ListItem.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 28/03/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import Foundation
import CoreData

class ListItem: NSManagedObject {

    @NSManaged var text: String
    @NSManaged var complete: NSNumber
    @NSManaged var relationship: List

}
