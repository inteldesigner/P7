//
//  TodayVC.swift
//  FocOnApp1
//
//  Created by Eric Stein on 12/28/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class TodayVC: UITableViewController, UITextViewDelegate {
    
    // MARK: - Variables
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<FocOn>!
    private let formatter = DateFormatter()
    // Global goal variable to hold the latest goal entered
    private var goal: FocOn!
    private let taskCell = TaskCustomStaticTableViewCell()
        
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Goal Cell outlets
    
    @IBOutlet private weak var checkmarkButton: UIButton!
    @IBOutlet private(set) weak var goalCaption: UITextView!
//    //configure a cell: 241
    @IBOutlet private weak var goalCustomCell: UITableViewCell!
    
    // MARK: - Goal Cell actions
    
    @IBAction private func checkButtonPressed(_ sender: Any) {
        checkmarkButton.isSelected = !checkmarkButton.isSelected
        // Calling the delegate method textViewDidChange to update the CoreData database with the change of checkmarkButton isSelected status
        textViewDidChange(goalCaption)
        checkmarkButton.isSelected ?
            displayAlertAnimation(title: "Good Job!", message: "Wonderful, you achieved your goal!") :
            displayAlertAnimation(title: "No problem, you will make it next time!", message: "Don't give up")
        // to update the notification captions
        manageLocalNotifications()
    }
    //MARK:- ANIMATION DISPLAY
    // to promote the user with an animation when marking a task or a goal as ‘completed’ or to ‘undo’ an action
    private func displayAlertAnimation(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
          // your code with delay
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
    // alert action when the application is launched in the day to give user the option to show again the last uncompleted goal as (today's goal)
    private func displayAlertAction() {
        let alert = UIAlertController(title: "Your goal is not achieved yet!", message: "Would you like to re-list it as today's goal?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            self.clearOldGoalsAndTasks()
        }))
        // show again last uncompleted goal and the tasks(by changing the creation date)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let goal = self.fetchedRC?.object(at: IndexPath(row: self.dayIndexPathRow(forSection: 0), section: 0))
            goal?.cd = self.removeTime(fromDate: Date())
            self.appDelegate.saveContext()
            self.goal = goal
            for indexPathRow in 0...2 {
                let task = self.fetchedRC?.object(at: IndexPath(row: indexPathRow + self.dayIndexPathRow(forSection: 1), section: 1))
                task?.cd = self.removeTime(fromDate: Date())
                self.appDelegate.saveContext()
            }
        }))
        self.present(alert, animated: true)
    }
    
    //clearing all tasks and goal
    private func clearOldGoalsAndTasks() {
        goalCaption.text = ""
        let goal = FocOn(entity: FocOn.entity(), insertInto: self.context)
        goal.caption = ""
        goal.kind = false
        goal.cd = self.removeTime(fromDate: Date())
        goal.completed = false
        appDelegate.saveContext()
        self.goal = goal
        for _ in 0...2 {
            let newTask = FocOn(entity: FocOn.entity(), insertInto: context)
            
            newTask.caption = ""
            newTask.completed = false
            newTask.cd = self.removeTime(fromDate: Date())
            newTask.kind = true
            
            appDelegate.saveContext()
            refresh()
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1), IndexPath(row: 1, section: 1), IndexPath(row: 2, section: 1)], with: .automatic)
    }
    
    //removing date
    private func removeTime(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // begin and end updates of the tableview to make sure cells are expanding simultanesously with the caption text inside the textView
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if WeDontHaveA(goal: goal) {
            let goal = FocOn(entity: FocOn.entity(), insertInto: context)
            goal.caption = textView.text!
            goal.completed = checkmarkButton.isSelected
            //current date
            goal.cd = removeTime(fromDate: Date())
            goal.kind = false
            appDelegate.saveContext()
            self.goal = goal
        } else {
            goal.caption = textView.text!
            goal.completed = checkmarkButton.isSelected
            appDelegate.saveContext()
        }
    }
    // checking if we do not have a goal today by comparing the creation date day of the last goal stored in the database with today's date
    func WeDontHaveA(goal: FocOn?) -> Bool {
        if let todaysGoal = goal {
            let dayOfCreation = formatter.calendar.component(.day, from: todaysGoal.cd!)
            let todaysDay = formatter.calendar.component(.day, from: Date())
            if dayOfCreation != todaysDay {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    // MARK: - Configuration:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        //MARK: - Animation Title
                          //to animate the title letters
                          titleLabel.text = ""
                          var charIndex = 0.0
                          let titleText = "🌱Focus On Today"
                          for letter in titleText {
                              print("-")
                              print(0.1 * charIndex)
                              print(letter)
                              Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                                  self.titleLabel.text?.append(letter)
                          }
                              charIndex += 1
                      }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if WeDontHaveA(goal: goal) {
            if isThereGoalToFetch(localFetchedRC: fetchedRC as! NSFetchedResultsController<NSFetchRequestResult>) {
                if goal.completed == false {
                    displayAlertAction()
                } else {
                    clearOldGoalsAndTasks()
                    checkmarkButton.isSelected = !checkmarkButton.isSelected
                    configureTextview()
                }
            }
        }
        configureTextview()
        manageLocalNotifications()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func configure() {
        registerCell()
        goalCaption.delegate = self
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        refresh()
        configureTapGesture()
    }
    
    // tapGesture to hide keyboard when tapped anywhere on the tabelview
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("hideKeyboard")))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    //Textview configuration:
    private func configureTextview() {
        if goalCaption.text.isEmpty {
            goalCaption.text = "Set your goal..."
            goalCaption.textColor = UIColor.lightGray
//            goalCaption.font = UIFont.italicSystemFont(ofSize: 20)
        }
    }
    
    //Editing textView beginning
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    //editing textView Ending
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Set your goal..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    //end editing text
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
    }

     private func registerCell() {
          let cell = UINib(nibName: "TaskCustomStaticTableViewCell", bundle: nil)
          tableView.register(cell, forCellReuseIdentifier: "customCell")
      }
    
    // MARK: - Table view data source
    //goal to Fetch Results Controller
    private func dayIndexPathRow(forSection: Int) -> Int {
            switch forSection {
            case 0:
                if isThereGoalToFetch(localFetchedRC: fetchedRC as! NSFetchedResultsController<NSFetchRequestResult>) {
                    return (fetchedRC.sections?[forSection].numberOfObjects)! - 1 // because index startsfrom 0 and we have only one goal every day
                }
            case 1:
                if isThereTaskToFetch(localFetchedRC: fetchedRC as! NSFetchedResultsController<NSFetchRequestResult>) {
                    return (fetchedRC.sections?[forSection].numberOfObjects)! - 3 // because index starts from 0 and we have three tasks every day
                }
            default:
            return 0
            }
        return 0
    }
    
    
    //configure a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                if validateIndexPath(IndexPath(row: indexPath.row + dayIndexPathRow(forSection: indexPath.section), section: indexPath.section), fetchedRC: fetchedRC as! NSFetchedResultsController<NSFetchRequestResult>) {
                    if let goal = fetchedRC?.object(at: IndexPath(row: indexPath.row + dayIndexPathRow(forSection: indexPath.section), section: indexPath.section)) {
                        goalCaption.text = goal.caption
                        checkmarkButton.isSelected = goal.completed
                        self.goal = goal
                        return goalCustomCell
                    } else {
                        return goalCustomCell
                    }
                } else {
                    print("trying to configure a cell for an indexPath: \(indexPath)")
                    return goalCustomCell
            }
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as? TaskCustomStaticTableViewCell else {
                    return UITableViewCell()
                }
                // make UITableViewCell to follow the height of the UITextView
                cell.textChanged { [weak tableView] (newText: String) in
                    // make updating the tableview happens in the main thread to avoid a weird scrolling behavior caused by the conflict between the focusing of the cursor and the layout of the tableView
                    DispatchQueue.main.async {
                        // tell tableView just to re-layout itself
                        tableView?.beginUpdates()
                        tableView?.endUpdates()
                    }
                }
                
                //adding number in UI and set tasks in cells placeholder
                cell.taskNumber.image = UIImage(named: "\(indexPath.row + 1)-number")
                cell.taskCaption.tag = indexPath.row + dayIndexPathRow(forSection: indexPath.section)
                cell.checkmarkButton.tag = indexPath.row + dayIndexPathRow(forSection: indexPath.section)
                if validateIndexPath(IndexPath(row: indexPath.row + dayIndexPathRow(forSection: indexPath.section), section: indexPath.section), fetchedRC: fetchedRC as! NSFetchedResultsController<NSFetchRequestResult>) {
                    //ResultsController
                    if let task = fetchedRC?.object(at: IndexPath(row: indexPath.row + dayIndexPathRow(forSection: indexPath.section), section: indexPath.section)) {
                        if task.caption == "" || cell.taskCaption.text == "" {
                            cell.taskCaption.textColor = UIColor.lightGray
                            cell.taskCaption.text = "Set your task"
                        } else {
                            cell.taskCaption.textColor = UIColor.darkGray
                            cell.taskCaption.text = task.caption
                        }
                        cell.checkmarkButton.isSelected = task.completed
                        return cell
                    } else {
                        return cell
                    }
                } else {
                    return cell
            }
            default:
            return UITableViewCell()
        }
    }
    
    // MARK: - helper functions:

    private func refresh() {
        let request = FocOn.fetchRequest() as NSFetchRequest<FocOn>
        let sort    = NSSortDescriptor(key: #keyPath(FocOn.kind), ascending: true)
        request.sortDescriptors = [sort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(FocOn.kind), cacheName: nil)
        do {
            fetchedRC.delegate = self
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func validateIndexPath(_ indexPath: IndexPath,fetchedRC: NSFetchedResultsController<NSFetchRequestResult>) -> Bool {
        if let sections = fetchedRC.sections,
        indexPath.section < sections.count {
           if indexPath.row < sections[indexPath.section].numberOfObjects {
              return true
           }
        }
        return false
    }
    
    // making sure that there's a goal to fetch
    private func isThereGoalToFetch(localFetchedRC: NSFetchedResultsController<NSFetchRequestResult>) -> Bool {
            if localFetchedRC.sections?.count != 0 {
                    return true
            }
        return false
    }
    // making sure that there's a task to fetch
    private func isThereTaskToFetch(localFetchedRC: NSFetchedResultsController<NSFetchRequestResult>) -> Bool {
        if isThereGoalToFetch(localFetchedRC: fetchedRC as! NSFetchedResultsController<NSFetchRequestResult>) {
            if localFetchedRC.sections?.count != 1 {
                    return true
            }
        } else {
            if localFetchedRC.sections?.count != 0 {
                    return true
            }
        }
        return false
    }
    
    // MARK: - Notifications
    
    private func manageLocalNotifications() {
        var title: String?
        var body: String?
        if WeDontHaveA(goal: goal) {
            title = "It's now time"
            body = "Set your goal for today"
        } else {
            title = "Hello"
            body = "What is your goal for today?"
        }
        scheduleLocalNotification(title: title, body: body)
    }
    //MARK:- LOCAL NOTIFICATION
    private func scheduleLocalNotification(title: String?, body: String?) {
        let identifier = "goalsListSummary"
        let notificationCenter = UNUserNotificationCenter.current()
        // remove previously scheduled notifications
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        if let newTitle = title, let newBody = body {
            // create content
            let content = UNMutableNotificationContent()
            content.title = newTitle
            content.body = newBody
            content.sound = UNNotificationSound.default
            // create trigger
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10800, repeats: true)
            // create request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            // schedule notification
            notificationCenter.add(request, withCompletionHandler: nil)
        }
        
    }
}

// Fetched Results Controller delegate:
extension TodayVC: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            checkmarkButton.isSelected = goal.completed
        default:
            break
        }
    }
}
