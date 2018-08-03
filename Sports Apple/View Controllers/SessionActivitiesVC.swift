//
//  SessionActivitiesVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JGProgressHUD
import AWSCognitoIdentityProvider

class SessionActivitiesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sessionActivitiesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var session: Activity = Activity()
    var array: [ExerciseItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getActivities()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateExercise(notification:)), name: .updateExercise, object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityTVCell
        cell.commentLabel.text = array[indexPath.row].exerciseComment
        cell.nameLabel.text = array[indexPath.row].exerciseName
        
        if array[indexPath.row].exerciseWeightAmount != 0 {
            
            cell.weightLabel.isHidden = false
            cell.setsLabel.isHidden = false
            cell.repsLabel.isHidden = false
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = true
            
            cell.weightLabel.text = String(array[indexPath.row].exerciseWeightAmount) + " lbs"
            cell.setsLabel.text = String(array[indexPath.row].exerciseSets) + " Sets"
            cell.repsLabel.text = String(array[indexPath.row].exerciseReps) + " Reps"
        }
        else if array[indexPath.row].exerciseDistance != 0 {
            cell.weightLabel.isHidden = true
            cell.setsLabel.isHidden = true
            cell.repsLabel.isHidden = true
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = false
            
            cell.distanceTimeLabel.text = String(array[indexPath.row].exerciseDistance) + " miles"
        }
        else if array[indexPath.row].exerciseTime != 0 {
            cell.weightLabel.isHidden = true
            cell.setsLabel.isHidden = true
            cell.repsLabel.isHidden = true
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = false
            let hours = array[indexPath.row].exerciseTime / 3600
            let minutes = (array[indexPath.row].exerciseTime / 60) % 60
            cell.distanceTimeLabel.text = String(format: "%02d:%02d", hours, minutes)
        }
        else if array[indexPath.row].exerciseCount != 0 {
            cell.weightLabel.isHidden = true
            cell.setsLabel.isHidden = true
            cell.repsLabel.isHidden = true
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = false
            
            cell.distanceTimeLabel.text = String(array[indexPath.row].exerciseCount) + " Counts"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            var exerciseList = self.session._exerciseList
            exerciseList?.remove(at: index.row)
            self.session._exerciseList = exerciseList
            
            for (key, value) in (exerciseList?.enumerated())! {
                print("Key: ", key)
                print("Value: ", value)
            }
            
            if exerciseList!.count > 0 {
                self.showHUD(hud: self.hud!)
                self.session.createActivity(activityItem: self.session, completion: { (response) in
                    DispatchQueue.main.async {
                        self.hideHUD(hud: self.hud!)
                        if response == "success" {
                            self.array.remove(at: index.row)
                            self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
                            self.showSuccessHUD(text: "Activity deleted")
                        }
                        else {
                            self.showErrorHUD(text: response)
                        }
                    }
                })
            }
            else {
                self.showHUD(hud: self.hud!)
                self.session.deleteActivity(activityItem: self.session, completion: { (response) in
                    DispatchQueue.main.async {
                        self.hideHUD(hud: self.hud!)
                        if response == "success" {
                            self.array.remove(at: index.row)
                            self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
                            self.showSuccessHUD(text: "Session deleted")
                            NotificationCenter.default.post(name: .refreshActivity, object: nil)
                        }
                        else {
                            self.showErrorHUD(text: response)
                        }
                    }
                    
                })
            }
            

            
        }
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let storyboard = UIStoryboard(name: "AddActivityInSession", bundle: nil)
            let destVC = storyboard.instantiateViewController(withIdentifier: "ExerciseDetailsVC") as! ExerciseDetailsVC
            destVC.oldActivity = self.session
            destVC.oldExercise = self.array[index.row]
            self.present(destVC, animated: true, completion: .none)
        }
        edit.backgroundColor = UIColor.init(hex: "#3681CC")
        
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func setupViews() {
        self.hud = self.createLoadingHUD()
         self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
    }
    
    func getActivities() {
        if session._exerciseList!.count > 0 {
            array = Array()
            let dict = session._exerciseList
            
            for value in dict! {
                let exerciseItem = ExerciseItem(exerciseID: "\(value["exerciseID"] ?? 0)", exerciseName: "\(value["exerciseName"] ?? "")", exerciseWeightAmount: Int("\(value["Weight Amount"] ?? 0)")!, exerciseCount: Int("\(value["Count"] ?? 0)")!, exerciseReps: Int("\(value["Reps"] ?? 0)")!, exerciseSets: Int("\(value["Sets"] ?? 0)")!, exerciseTime: Int("\(value["Time"] ?? 0)")!, exerciseDistance: Int("\(value["Distance"] ?? 0)")!, exerciseComment: "\(value["Exercise Comment"] ?? "")")
                
                array.append(exerciseItem)
            }
            tableView.reloadData()
        }
        else {
            tableView.isHidden = true
            sessionActivitiesLabel.isHidden = false
        }
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func updateExercise(notification: Notification) {
        getActivities()
    }

    

}
