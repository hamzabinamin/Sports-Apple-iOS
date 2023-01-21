//
//  UserSettingsVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 10/17/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserSettingsVC: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!

    var user = User()
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 20
        saveButton.clipsToBounds = true
        
        if(self.retrieveUser() != nil) {
            user = self.retrieveUser()!
            nameTF.text = user.getFullName()
            phoneNumberTF.text = user.phoneNumber
       }
        hideKeyboard()
    }

    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        if(validation()) {
            let name = nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let phoneNumber = phoneNumberTF.text!
            
            if isConnectedToNetwork() {
                updateUser(name: name!, phoneNumber: phoneNumber)
            }
            else {
                 createAlert(titleText: "Note", messageText: "Please connect to the Internet")
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
    
    func validation() -> Bool {
        let name = nameTF.text!
        let phoneNumber = phoneNumberTF.text!
        
        if name.count > 0 && phoneNumber.count > 0 {
            
            return true
        }
        else {
            createAlert(titleText: "Note", messageText: "Please fill all the fields")
            return false
        }
        
    }
    
    func activityIndicator(_ title: String) {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func updateUser(name: String, phoneNumber: String) {
        activityIndicator("Please Wait")
        AF.request("https://schools-live.com/app/apis/updateUser.php", parameters: ["name": name, "phonenumber" : phoneNumber])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                            self.effectView.isHidden = true
                            self.createAlert(titleText: "Account Updated", messageText: "Account Updated Successfully")
                            let store = User()
                            store.firstName = name
                            store.phoneNumber = phoneNumber
                            store.lastUpdateTime = self.user.lastUpdateTime
                            store.totalUpdates = self.user.totalUpdates
                    
                            self.saveUser(user: store)
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
}

extension UIViewController {
    
    func retrieveUser() -> User? {
        if let data = UserDefaults.standard.data(forKey: "User"),
            let user = try? JSONDecoder().decode(User.self, from: data) {
            
            return user
        }
        else {
            return nil
        }
       /* do {
            if let data = UserDefaults.standard.data(forKey: "User"),
               let user = try NSKeyedUnarchiver.unarchivedObject(ofClass: User.self, from: data) {
                return user
            } else {
                return nil
            }
        }
        catch {
            print(error)
        }
       return nil */
    }
    
    func saveUser(user: User) {
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "User")
        }
        catch {
            print(error)
        }
    }
}


