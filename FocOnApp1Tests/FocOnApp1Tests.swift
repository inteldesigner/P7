//
//  FocOnApp1Tests.swift
//  FocOnApp1Tests
//
//  Created by Eric Stein on 1/18/20.
//  Copyright © 2020 Eric Stein. All rights reserved.
//

import XCTest
import CoreData
@testable import FocOnApp1

class DataControllerTestCase: XCTestCase {

    var dataController: DataController!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<FocOn>!
    
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
        
        let allGoals = fetchedRC.sections?[0].objects as? [FocOn]
        let monthlyFetchedArrayFromAllGoals = dataController.monthly(goals: allGoals!)
        let monthlyFetchedArray = dataController.monthly(goals: dataController.allGoalsObjects(achieved: false)!)
        XCTAssertTrue(monthlyFetchedArrayFromAllGoals == monthlyFetchedArray, "Monthly arrays aren't equal")
    }
    
    func testGivenDataController_WhenWeeklyGivenAllObjectsMethodArryaAndFetchedRCObjectsArray_ThenReturnedArrayElementsAreOfTheSame() {
        
        let allGoals = fetchedRC.sections?[0].objects as? [FocOn]
        let weeklyFetchedArrayFromAllGoals = dataController.weekly(goals: allGoals!)
        let weeklyFetchedArray = dataController.weekly(goals: dataController.allGoalsObjects(achieved: false)!)
        XCTAssertTrue(weeklyFetchedArrayFromAllGoals == weeklyFetchedArray, "Weekly arrays aren't equal")
    }
    
    private func refresh() {
        let request = FocOn.fetchRequest() as NSFetchRequest<FocOn>
        let sort    = NSSortDescriptor(key: #keyPath(FocOn.kind), ascending: true)
        request.sortDescriptors = [sort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(FocOn.kind), cacheName: nil)
        do {
            fetchedRC.delegate = self as? NSFetchedResultsControllerDelegate
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
