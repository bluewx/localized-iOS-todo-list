//
//  List.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 28/03/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import Foundation
import CoreData

class List: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var date: NSDate
    @NSManaged var relationship: NSOrderedSet

}
