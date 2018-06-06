//
//  SettingsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let array = ["Profile", "WeekLink" , "Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
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
        
        if indexPath.row == 2 {
            let storyboard = UIStoryboard(name: "LogOut", bundle: nil)
            let destVC = storyboard.instantiateViewController(withIdentifier: "LogOutVC")
            self.present(destVC, animated: true, completion: .none)
        }
        
    }
    
    func goToLogOutVC() {
        
    }

}
