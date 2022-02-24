//
//  ProgressViewController.swift
//  BrushYourTeeth
//
//  Created by Hakeem Deggs on 2/17/22.
//

import UIKit
import CoreData

class ProgressViewController: UIViewController, SaveContextProtcol {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var dayOfWeek = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let daysOfWeek = ["Monday","Tuesday","Wednesday", "Thursday", "Friday","Saturday","Sunday"]
    var progressArray = [Days]()
    var weekday = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //file path for to view coredata
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.delegate = self
        tableView.dataSource = self
        checkNotificationStatus()
        loadDays()
        
        //creates day of week
        let date = Date.now
        let dateform = DateFormatter()
        dateform.dateFormat = "EEEE"
        let dayOfWeekString = dateform.string(from: date)
        
        switch dayOfWeekString {
            
        case "Monday":
            dayOfWeek = 0
            weekday = "Monday"
        case "Tuesday":
            dayOfWeek = 1
            weekday = "Tuesday"
        case "Wednesday":
            dayOfWeek = 2
            weekday = "Wednesday"
        case "Thursday":
            dayOfWeek = 3
            weekday = "Thursday"
        case "Friday":
            dayOfWeek = 4
            weekday = "Friday"
        case "Saturday":
            dayOfWeek = 5
            weekday = "Saturday"
        default:
            dayOfWeek = 6
            weekday = "Sunday"
        }
        
        tableView.register(UINib(nibName: "ProgressTableViewCell", bundle: nil), forCellReuseIdentifier: "ProgressCell")
        
        notificationCenter.getPendingNotificationRequests { notificationsRequests in
            
            //print(notificationsRequests.count)
            
        }
    }
    
    func saveContext() {
        
        do {
            try context.save()
            print("Data was saved successfully.")
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
            }
            
        } catch {
            print("🤬: couldn't save to context. \(error.localizedDescription)")
        }
    }
    
    func loadDays() {
        
        let request : NSFetchRequest<Days> = Days.fetchRequest()
        
        do {
            progressArray = try context.fetch(request)
            
        } catch{
            
            print("🤬: couldn't save to context. \(error.localizedDescription)")
        }
    }
}

extension ProgressViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        progressArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell", for: indexPath) as! ProgressTableViewCell
        cell.weekDays.text = progressArray[indexPath.row].day
        cell.morningSwitch.isOn = progressArray[indexPath.row].morning
        cell.nightSwitch.isOn = progressArray[indexPath.row].night
        cell.delegate = self
        
        if cell.weekDays.text != weekday {
            
            cell.weekDays.textColor = .placeholderText
            cell.morningSwitch.isEnabled = false
            cell.nightSwitch.isEnabled = false
            cell.morningTextLabel.textColor = .placeholderText
            cell.nightTextLabel.textColor = .placeholderText
            cell.morningSwitch.thumbTintColor = .white
            cell.nightSwitch.thumbTintColor = .white
            
        } else {
            
            cell.weekDays.textColor = .black
            cell.morningTextLabel.textColor = .black
            cell.nightTextLabel.textColor = .black
            cell.morningSwitch.thumbTintColor = .white
            cell.nightSwitch.thumbTintColor = .white
            cell.morningSwitch.isEnabled = true
            cell.nightSwitch.isEnabled = true
            
        }
        return cell
    }
}

extension ProgressViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

extension ProgressViewController {
    
    func checkNotificationStatus() {
        
        self.notificationCenter.getNotificationSettings { notificationSettings in
            DispatchQueue.main.async {
                
                if notificationSettings.authorizationStatus == .authorized {
                    self.notificationCenter.requestAuthorization(options: [.alert, .sound]) { success, error in
                        
                        if success {
                            
                            print("😊: You have authorization.")
                            
                        } else {
                            print("\(String(describing: error?.localizedDescription))")
                        }
                    }
                    
                } else {
                    let action = UIAlertController(title: "Enable Notifications?", message: "To use this feature you will need to enable notifications in settings", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Settings", style: .default) { (_) in
                        
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else
                        {
                            return
                        }
                        if (UIApplication.shared.canOpenURL(settingsURL)) {
                            UIApplication.shared.open(settingsURL) { _ in }
                        }
                    }
                    action.addAction(goToSettings)
                    action.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in }))
                    self.present(action, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func saveContext(morning: Bool, night: Bool) {
        
        let day = Days(context: context)
        day.setValue(weekday, forKeyPath:"day")
        day.setValue(night, forKeyPath: "night")
        day.setValue(morning, forKeyPath: "morning")
        saveContext()
    }
}
