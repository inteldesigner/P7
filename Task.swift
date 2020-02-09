//
//  Task.swift
//  FocOnApp1
//
//  Created by Eric Stein on 1/1/20.
//  Copyright © 2020 Eric Stein. All rights reserved.
//

import Foundation
import CoreData


public class Task: NSManagedObject {

}


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var achievedAt: Date?
    @NSManaged public var achievedGoal: String?
    @NSManaged public var achievedTasks: NSObject?
    @NSManaged public var captionGoal: String?
    @NSManaged public var captionTask: NSObject?

}
