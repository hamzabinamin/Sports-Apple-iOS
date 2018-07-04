//
//  GoalsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/6/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JGProgressHUD
import AWSCognitoIdentityProvider

class GoalsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var noGoalsLabel: UILabel!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var array: [Goal] = []
    let goal: Goal = Goal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        self.showHUD(hud: hud!)
        goal.queryGoal(userId: (pool?.currentUser()?.username)!) { (response, responseArray) in
            if response == "success" {
                self.array = responseArray
                
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    self.noGoalsLabel.isHidden = true
                    self.tableView.reloadData()
                }
                
            }
            else {
                DispatchQueue.main.async {
                    self.showErrorHUD(text: response)
                    self.noGoalsLabel.isHidden = false
                }
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GoalsTVCell
        let goal = array[indexPath.row]
        cell.activityLabel.text = goal._exerciseId
        
        if goal._time != nil {
            cell.goalTypeLabel.text = "Time Goal"
            cell.goalAmountLabel.text = "\((goal._time!.intValue) / 3600)" + ":" + "\((goal._time!.intValue) / 60)"
        }
        else if goal._weight != nil {
            cell.goalTypeLabel.text = "Weight Goal"
            cell.goalAmountLabel.text = "\(goal._weight!)" + " lbs"
        }
        else if goal._time != nil {
            cell.goalTypeLabel.text = "Time Goal"
            cell.goalAmountLabel.text = Int(goal._time!).msToSeconds.minuteSecond
        }
        else if goal._calories != nil {
            cell.goalTypeLabel.text = "Calories Goal"
            cell.goalAmountLabel.text = "\(goal._calories!)" + " calories"
        }
        else if goal._distance != nil {
            cell.goalTypeLabel.text = "Distance Goal"
               cell.goalAmountLabel.text = "\(goal._distance!)" + " miles"
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setupViews() {
        self.hud = self.createLoadingHUD()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.tableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToAddGoalVC))
        addImageView.isUserInteractionEnabled = true
        addImageView.addGestureRecognizer(tap)
    }
    
    @objc func goToAddGoalVC() {
        let storyboard = UIStoryboard(name: "AddGoal", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddGoalVC")
        self.present(destVC, animated: true, completion: .none)
    }

}
