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

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var noGoalsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var array: [Goal] = []
    let goal: Goal = Goal()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getGoals()

        NotificationCenter.default.addObserver(self, selector: #selector(getGoals), name: .refreshGoals, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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
        formatter.dateFormat = "MM/dd/yyyy h:mm a"
        let date = formatter.date(from: goal._date!)
        formatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel.text = formatter.string(for: date)
        
        if goal._yearlyGoal == "Yes" {
            cell.yearlyGoal.isHidden = false
        }
        else {
            cell.yearlyGoal.isHidden = true
        }
        
        if goal._time != nil {
            cell.goalTypeLabel.text = "Time Goal"
            let hours = (goal._time?.intValue)! / 3600
            let minutes = ((goal._time?.intValue)! / 60) % 60
            cell.goalAmountLabel.text = String(format: "%02d:%02d", hours, minutes)
        }
        else if goal._weight != nil {
            cell.goalTypeLabel.text = "Weight Goal"
            cell.goalAmountLabel.text = "\(goal._weight!)" + " lbs"
            
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
        self.formatter.dateFormat = "MM/dd/yyyy"
        
        addButton.addTarget(self, action: #selector(goToAddGoalVC), for: .touchUpInside)
    }
    
    @objc func getGoals() {
        self.showHUD(hud: hud!)
        goal.queryGoal(userId: (pool?.currentUser()?.username)!) { (response, responseArray) in
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            if response == "success" {
                self.array = responseArray
                
                DispatchQueue.main.async {
                    self.noGoalsLabel.isHidden = true
                    self.tableView.reloadData()
                }
                
            }
            else {
                DispatchQueue.main.async {
                    
                    if response == "failure" {
                        self.noGoalsLabel.isHidden = false
                    }
                    else {
                        self.showErrorHUD(text: response)
                        self.noGoalsLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    @objc func goToAddGoalVC() {
        let storyboard = UIStoryboard(name: "AddGoal", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddGoalVC")
        self.present(destVC, animated: true, completion: .none)
    }

}
