//
//  NotificationsVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 10/17/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationSwitch.addTarget(self, action:#selector(toggleSwitch(_sender:)), for: .valueChanged)

        if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
            
            if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                DispatchQueue.main.async {
                    self.notificationSwitch.isOn = true
                }
            }
        }

    }

    func createAlert(titleText: String, messageText: String) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        
    }
    
    @objc func toggleSwitch(_sender: UISwitch) {
        if _sender.isOn == true {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
                
                if error != nil {
                    self.notificationSwitch.isOn = false
                    UserDefaults.standard.set(false, forKey: "Notification Switch")
                    print("Authorization Unsuccessful")
                }
                else {
                    DispatchQueue.main.async {
                        self.createAlert(titleText: "Notifications Activiated", messageText: "Notifications got activated")
                    }
                    UserDefaults.standard.set(true, forKey: "Notification Switch")
                    print("Authorization Successful")
                }
            }
        }
        else {
            UserDefaults.standard.set(false, forKey: "Notification Switch")
        }
    }

}

extension UIViewController {
    
    func saveNotificationArray(notificationArray: [Game]) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: notificationArray, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "Notification Array")
        }
        catch {
            print(error)
        }
        
    }
    
}
