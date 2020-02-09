//
//  TaskCustomStaticTableViewCell.swift
//
//  FocOnApp1
//
//  Created by Eric Stein on 12/28/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import UIKit
import CoreData


class TaskCustomStaticTableViewCell: UITableViewCell {
    
    // MARK: - Variables
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<FocOn>!
    private let formatter = DateFormatter()
    private var task: FocOn!
    // create a callback from the cell to inform us on any text changes just so that Cell can follow the height of the UITextView.
    private var textChanged: ((String) -> Void)?


    // MARK: - Outlets
    
    @IBOutlet weak var taskNumber: UIImageView!
    @IBOutlet weak var taskCaption: UITextView!
    @IBOutlet weak var checkmarkButton: UIButton!
    
}

extension TaskCustomStaticTableViewCell: UITextViewDelegate {
    
    
    // MARK: - Actions
    private func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // create a callback from the cell to inform us on any text changes so UITableViewCell can follow the height of the UITextView.
        textChanged?(textView.text)
        refresh()
        if weDontHaveAGoal(localFetchedRC: fetchedRC as! NSFetchedResultsController<NSFetchRequestResult>) {
            textView.text = "Set your goal first"
            textView.textColor = UIColor.red
        } else {
            textView.textColor = UIColor.black
            if isItNotTheSameDay(forThisTask: textView.tag) {
                textView.text = ""
                let newTask = FocOn(entity: FocOn.entity(), insertInto: context)
                newTask.caption = textView.text!
                newTask.completed = checkmarkButton.isSelected
                newTask.cd = removeTimeStamp(fromDate: Date())
                newTask.kind = true
                appDelegate.saveContext()
                if shallIncrementTextViewTag(forThisTag: textView.tag) {
                    textView.tag += 3
                }
            } else {
                let task = fetchedRC.object(at: IndexPath(row: textView.tag, section: 1))
                task.caption = textView.text!
                task.completed = checkmarkButton.isSelected
                appDelegate.saveContext()
            }
        }
    }
    
    private func shallIncrementTextViewTag(forThisTag: Int) -> Bool {
        if     forThisTag != 0
            || forThisTag != 1
            || forThisTag != 2 {
            return false
        } else {
            return true
        }
    }
    
    
    
    // check if last created task is created today or in past days
    func isItNotTheSameDay(forThisTask: Int) -> Bool {
        refresh()
        // this condition is when the app is opened for the first time
        if fetchedRC.sections?.count == 0 || fetchedRC.sections?.count == 1 {
            return true
        }
        // forThisTask is the textView tag property which's assigned the indexPath.row
        // if this condition is true that means we haven't created tasks yet
        if forThisTask + 1 > (fetchedRC.sections?[1].numberOfObjects)! {
           return true
        }
        let task = fetchedRC?.object(at: IndexPath(row: forThisTask, section: 1))
        let dayOfCreation = formatter.calendar.component(.day, from: (task?.cd!)!)
            let todaysDay = formatter.calendar.component(.day, from: Date())
                if dayOfCreation != todaysDay {
                    return true
                } else {
                    return false
                }
        }
    
    // this func is merely to prevent app from crashing when there's no data in database when app first launched by a user
    private func weDontHaveAGoal(localFetchedRC: NSFetchedResultsController<NSFetchRequestResult>) -> Bool {
            if localFetchedRC.sections?.count == 0 {
                    return true
            }
        return false
    }
    
    // create a callback from the cell to inform us on any text changes so UITableViewCell can follow the height of the UITextView.
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
   
        
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
    }

    @IBAction func checkmarkButtonPressed(_ sender: UIButton) {
        checkmarkButton.isSelected = !checkmarkButton.isSelected
        let task = fetchedRC.object(at: IndexPath(row: sender.tag, section: 1))
        task.completed = checkmarkButton.isSelected
        appDelegate.saveContext()
        if isAllTasksCompleted() {
            displayAlertAction()
        } else {
            if checkmarkButton.isSelected == true {
                let alert = UIAlertController(title: "Nice, you are making progress! 👍🏻", message: nil, preferredStyle: UIAlertController.Style.alert)
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func displayAlertAction() {
            let alert = UIAlertController(title: "You have marked all tasks as completed", message: "Would you like to mark goal as completed as well?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                let todaysGoalIndex = (self.fetchedRC.sections?[0].numberOfObjects)! - 1
                let goal = self.fetchedRC.object(at: IndexPath(row: todaysGoalIndex, section: 0))
                goal.completed = true
            }))
            let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
            keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    // this func to check if all tasks are completed so we can promote user with an option to mark goal completed
    func isAllTasksCompleted() -> Bool {
        refresh()
        
        let todaysFirstTaskIndex = (fetchedRC.sections?[1].numberOfObjects)! - 3
        let todaysLastTaskIndex = (fetchedRC.sections?[1].numberOfObjects)! - 1
        let todaysTasksCount = todaysLastTaskIndex - todaysFirstTaskIndex + 1
        
        var numberOfCompletedTasks = 0
        
        for taskIndexPathRow in todaysFirstTaskIndex...todaysLastTaskIndex {
            let task = fetchedRC.object(at: IndexPath(row: taskIndexPathRow, section: 1))
            
            if task.completed == true {
                numberOfCompletedTasks += 1
                if numberOfCompletedTasks == todaysTasksCount {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Configuration
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    private func configure() {
        taskCaption.delegate = self
        formatter.dateFormat = "dd MM yyyy"
        configureTextview()
        refresh()
    }
    
    
    func configureTextview() {
        taskCaption.delegate = self
        if taskCaption.text.isEmpty {
            taskCaption.text = "Set your task..."
            taskCaption.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            taskCaption.text = "Set your task..."
            taskCaption.textColor = UIColor.lightGray
        }
    }
    
    private func refresh() {
        let request = FocOn.fetchRequest() as NSFetchRequest<FocOn>
        let sort    = NSSortDescriptor(key: #keyPath(FocOn.kind), ascending: true)
        request.sortDescriptors = [sort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(FocOn.kind), cacheName: nil)
        do {
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

//} catch {
//    fatalError("Failed to fetch entities: \(error)")

