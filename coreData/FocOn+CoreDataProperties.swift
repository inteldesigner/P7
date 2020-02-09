//
//  FocOn+CoreDataProperties.swift
//  FocOnApp1
//
//  Created by Eric Stein on 12/28/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//
//

import Foundation
import CoreData


extension FocOn {
//Returns an array of objects that meet the criteria specified by a given fetch request...
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocOn> {
        return NSFetchRequest<FocOn>(entityName: "FocOn")
//        NSFetchRequest<Product>(entityName: "Product")
    }

}
