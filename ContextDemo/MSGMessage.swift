//
//  MSGMessage.swift
//  ContextDemo
//
//  Created by John Donley on 9/10/15.
//  Copyright (c) 2015 JohnDonley. All rights reserved.
//

import Foundation
import CoreData

class MSGMessage: NSManagedObject {

    @NSManaged var content: String
    @NSManaged var createdAt: NSDate
    @NSManaged var shouldShow: NSNumber

}
