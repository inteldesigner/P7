//
//  HistoryViewController.swift
//  FocOnApp1
//
//  Created by Eric Stein on 12/28/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//
import UIKit
import CoreData


class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var currentMonth: UILabel!
    @IBOutlet weak var totalNumberOfAchievedGoals: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
 
    
    // MARK: - Variables
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedRC: NSFetchedResultsController<FocOn>!
    private let formatter = DateFormatter()
    let data = DataController()
    
    // MARK: - Configuration
    
    private func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        refresh()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        currentMonth.text = formatter.string(from: removeTimeStamp(fromDate: Date()))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        refresh()
        tableView.reloadData()
        totalNumberOfAchievedGoals.text = "\(data.allGoalsObjects(achieved: true)?.count ?? 0) out of \(data.allGoalsObjects(achieved: false)?.count ?? 0) goals completed"
        }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedRC.sections, let objs = sections[section].objects else {
            return 0
        }
        return objs.count
    }
        //cells in historyView updating UI/ size- colors
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell") as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        if let toDo = fetchedRC?.object(at: reversedIndex(indexPath)) {
            if toDo.kind == false {
                cell.toDoCellLabel.font = cell.toDoCellLabel.font.withSize(25)
            } else {
                cell.toDoCellLabel.font = cell.toDoCellLabel.font.withSize(20)
            }
            if toDo.caption != "" {
                cell.toDoCellLabel.textColor = UIColor.darkGray
                cell.toDoCellLabel.text = toDo.caption
                
                //MARK:- delete tasks showing on historyView
                //what if i do not want to show the task achieved in the historyview but just the goal achieved?
                if toDo.completed {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            } else {
                //label not completed placeholder
                cell.toDoCellLabel.textColor = UIColor.lightGray
                cell.accessoryType = .none
                cell.toDoCellLabel.text = toDo.kind ? "Set this Task..." : "Set this Goal..."
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    private func reversedIndex(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: fetchedRC.sections!.count - 1 - indexPath.section)
    }
    
    private func reversedSectionIndex(_ indexPathSection: Int) -> Int {
        return fetchedRC.sections!.count - 1 - indexPathSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedRC.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let toDoObjects = fetchedRC.sections?[reversedSectionIndex(section)].objects as? [FocOn], let firstToDo = toDoObjects.first {
            let date = formatter.string(from: firstToDo.cd!)
            return date
        }
        return "doesn't work"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        } else {
            return 40
        }
    }
    // MARK: - Main private functions
    
    private func refresh() {
        let request = FocOn.fetchRequest() as NSFetchRequest<FocOn>
        let sort    = NSSortDescriptor(key: #keyPath(FocOn.kind), ascending: true)
        let date = NSSortDescriptor(key: #keyPath(FocOn.cd), ascending: true)
        request.sortDescriptors = [date, sort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(FocOn.cd), cacheName: nil)
        do {
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Secondary helper functions:
    
    private func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
}


