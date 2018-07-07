//
//  SettingsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import JGProgressHUD

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    let array = ["Profile", "WeekLink" , "Log Out"]
    let user: User = User()
    var userItem: UserItem = UserItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = self.createLoadingHUD()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        tableView.tableFooterView = UIView()
       
         NotificationCenter.default.addObserver(self, selector: #selector(goToLoginVC), name: .showLoginVC, object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingsTVCell
        cell.nameLabel.text = array[indexPath.row]
        
        if indexPath.row == 2 {
            cell.nameLabel.textColor = UIColor.red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            self.showHUD(hud: hud!)
            user.queryUser(userId: (pool?.currentUser()?.username)!) { (response, responseItem) in
                
                if response == "success" {
                    DispatchQueue.main.async {
                        self.userItem = responseItem
                        
                        self.pool?.currentUser()?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
                            DispatchQueue.main.async(execute: {
                                self.hideHUD(hud: self.hud!)
                                let response = task.result
                                let userAttribute = response?.userAttributes![2]
                                //print("Attribute Name: ", userAttribute?.name!)
                                print("Attribute Value: ", userAttribute!.value!)
                                self.userItem.email = userAttribute!.value!
                                self.goToSignUp1VC()
                            })
                            return nil
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.hideHUD(hud: self.hud!)
                    }
                }
            }
        }
        else if indexPath.row == 1 {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "http://www.fit1stclub.com/")!, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(URL(string: "http://www.fit1stclub.com/")!)
            }
        }
        else if indexPath.row == 2 {
            let storyboard = UIStoryboard(name: "LogOut", bundle: nil)
            let destVC = storyboard.instantiateViewController(withIdentifier: "LogOutVC")
            self.present(destVC, animated: true, completion: .none)
        }
        
    }
    
    @objc func goToLoginVC() {
      //  let storyboard = UIStoryboard(name: "Main", bundle: nil)
      //  let destVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
     //   self.navigationController?.pushViewController(destVC, animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func goToSignUp1VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp1VC") as! SignUp1VC
        destVC.user = userItem
        destVC.cameFromSettings = true
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}
