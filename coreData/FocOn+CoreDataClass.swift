//
//  FocOn+CoreDataClass.swift
//
//  FocOnApp1
//
//  Created by Eric Stein on 12/28/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import Foundation
import CoreData


//A base class that implements the behavior required of a Core Data model object
public class FocOn: NSManagedObject {
    @NSManaged public var caption: String?
     //current date
     @NSManaged public var cd: Date?
     @NSManaged public var completed: Bool
     @NSManaged public var kind: Bool

    
//    @NSManaged public var achievedTasks: NSObject?
//    @NSManaged public var achievedGoal: String?
}
