//
//  DataControllerTestCase.swift
//  FocusOnTests
//
//  Created by Ahmad Murad on 01/12/2019.
//  Copyright © 2019 Ahmad Murad. All rights reserved.
//

import XCTest
import CoreData
@testable import FocOnApp

class DataControllerTestCase: XCTestCase {

    var dataController: DataController!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<ToDo>!
    
    override func setUp() {
        super.setUp()
        refresh()
        dataController = DataController()
    }
    
    func testGivenDataController_WhenFetchingAllGoalsObjectsMethod_ThenAllFetchedGoalsEqualsAllFetchedObjects() {
        let fetchedGoals = dataController.allGoalsObjects(achieved: false)
        XCTAssertNotNil(fetchedGoals, "unable to fetch data")
        let fetchedObjects = fetchedRC.sections?[0].objects
        XCTAssert(fetchedGoals?.count == fetchedObjects?.count, "fetchedGoals count isn't equal to fetchedObjects")
    }
    
    func testGivenDataController_WhenMonthlyGivenAllObjectsMethodArryaAndFetchedRCObjectsArray_ThenReturnedArrayElementsAreOfTheSame() {
        
        let allGoals = fetchedRC.sections?[0].objects as? [ToDo]
        let monthlyFetchedArrayFromAllGoals = dataController.monthly(goals: allGoals!)
        let monthlyFetchedArray = dataController.monthly(goals: dataController.allGoalsObjects(achieved: false)!)
        XCTAssertTrue(monthlyFetchedArrayFromAllGoals == monthlyFetchedArray, "Monthly arrays aren't equal")
    }
    
    func testGivenDataController_WhenWeeklyGivenAllObjectsMethodArryaAndFetchedRCObjectsArray_ThenReturnedArrayElementsAreOfTheSame() {
        
        let allGoals = fetchedRC.sections?[0].objects as? [ToDo]
        let weeklyFetchedArrayFromAllGoals = dataController.weekly(goals: allGoals!)
        let weeklyFetchedArray = dataController.weekly(goals: dataController.allGoalsObjects(achieved: false)!)
        XCTAssertTrue(weeklyFetchedArrayFromAllGoals == weeklyFetchedArray, "Weekly arrays aren't equal")
    }
    
    private func refresh() {
        let request = ToDo.fetchRequest() as NSFetchRequest<ToDo>
        let sort    = NSSortDescriptor(key: #keyPath(ToDo.kind), ascending: true)
        request.sortDescriptors = [sort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(ToDo.kind), cacheName: nil)
        do {
            fetchedRC.delegate = self as? NSFetchedResultsControllerDelegate
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
