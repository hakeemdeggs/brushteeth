//
//  ViewController.swift
//  BrushYourTeeth
//
//  Created by Hakeem Deggs on 2/16/22.
//

import UIKit
import UserNotifications

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var morningDatePicker: UIDatePicker!
    @IBOutlet weak var nightDatePicker: UIDatePicker!
    var notificationsCount = 0
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {_,_ in }
        
        notificationCenter.getPendingNotificationRequests { notificationsRequests in
            
            if notificationsRequests.count > 1 {
                DispatchQueue.main.async {
                    
                    self.performSegue(withIdentifier: "GoToProgress", sender: self)
                }
            }
        }
    }
    
    
    @IBAction func createSchedule(_ sender: UIButton) {
        
        checkNotificationStatus()
        
    }
}

//MARK: - Check notification status then send alert if authorized


extension ScheduleViewController {
    
    func checkNotificationStatus() {
        
        self.notificationCenter.getNotificationSettings { notificationSettings in
            DispatchQueue.main.async {
                
                if notificationSettings.authorizationStatus == .authorized  {
                    
                    self.notificationCenter.requestAuthorization(options: [.alert, .sound]) { success, error in
                        
                        if success {
                            
                        } else {
                            print("\(String(describing: error?.localizedDescription))")
                        }
                    }
                    
                    let morningContent = UNMutableNotificationContent()
                    morningContent.title = "Start your day with a clean mouth"
                    morningContent.body = ""
                    morningContent.sound = UNNotificationSound.default
                    
                    
                    let nightContent = UNMutableNotificationContent()
                    nightContent.title = "End your day with a clean mouth"
                    nightContent.body = ""
                    nightContent.sound = .default
                    
                    let morningDate = self.morningDatePicker.date
                    let nightDate = self.nightDatePicker.date
                    
                    let morningDateComponents = Calendar.current.dateComponents([ .hour, .minute, .second], from: morningDate)
                    
                    let nightDateComponents =
                    Calendar.current.dateComponents([.hour, .minute, .second], from: nightDate)
                    
                    let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningDateComponents, repeats: true)
                    
                    let nightTrigger = UNCalendarNotificationTrigger(dateMatching: nightDateComponents, repeats: true)
                    
                    let morningString = UUID().uuidString
                    let nightString = UUID().uuidString
                    
                    let morningRequest = UNNotificationRequest(identifier: morningString, content: morningContent, trigger: morningTrigger)
                    
                    let nightRequest = UNNotificationRequest(identifier: nightString, content: nightContent, trigger: nightTrigger)
                    
                    self.notificationCenter.removeAllPendingNotificationRequests()
                    
                    self.notificationCenter.add(morningRequest) { error in }
                    
                    self.notificationCenter.add(nightRequest) { error in }
                    
                    self.notificationCenter.getPendingNotificationRequests {
                        
                        pendingNotifications in
                        self.notificationsCount = pendingNotifications.count
                        
                        print(self.notificationsCount)
                        
                        
                        if self.notificationsCount > 1 {
                            
                            DispatchQueue.main.async {
                                
                                self.performSegue(withIdentifier: "GoToProgress", sender: self)
                            }
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
    
    @IBAction func unwindToOne (_ sender: UIStoryboardSegue) {}
    
}


