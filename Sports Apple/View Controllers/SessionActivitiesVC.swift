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
   
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var sessionActivitiesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var session: Activity = Activity()
    var dict: [[String: Any]] = []
    var array: [ExerciseItem] = []
    var originalExerciseList: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getActivities()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateExercise(notification:)), name: .updateExercise, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView(notification:)), name: .updateActivityTV2, object: nil)
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
        print("Exercise Name is: ", array[indexPath.row].exerciseName)
        print("Weight is: ", array[indexPath.row].exerciseWeightAmount)
        
        if array[indexPath.row].exerciseWeightAmount != 0 {
            cell.weightLabel.isHidden = false
            cell.setsLabel.isHidden = false
            cell.repsLabel.isHidden = false
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = true
            
            cell.weightLabel.text = String(array[indexPath.row].exerciseWeightAmount) + " lbs"
            cell.setsLabel.text = String(array[indexPath.row].exerciseSets) + " sets"
            cell.repsLabel.text = String(array[indexPath.row].exerciseReps) + " reps"
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
            cell.distanceTimeLabel.text = String(format: "%02d:%02d", hours, minutes) + " time"
        }
        else if array[indexPath.row].exerciseCount != 0 {
            cell.weightLabel.isHidden = true
            cell.setsLabel.isHidden = true
            cell.repsLabel.isHidden = true
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = false
            
            cell.distanceTimeLabel.text = String(array[indexPath.row].exerciseCount) + " counts"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.showDeleteAlert(indexPath: index)
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
        self.originalExerciseList = self.session._exerciseList!
        addButton.addTarget(self, action: #selector(goToExerciseDetailsVC), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveSession), for: .touchUpInside)
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Activity Deletion", message: "Are you sure you want to delete this activity?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            var exerciseList = self.session._exerciseList
            exerciseList?.remove(at: indexPath.row)
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
                            self.originalExerciseList = exerciseList!
                            self.array.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                            self.sessionActivitiesLabel.isHidden = true
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
                            self.array.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                            self.sessionActivitiesLabel.isHidden = false
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
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmAlert() {
        let alertController = UIAlertController(title: "Update Session", message: "Would you like to update your session?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.saveSession()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            alertController.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func getActivities() {
        self.dict = []
        if session._exerciseList!.count > 0 {
            array = Array()
            let dict = session._exerciseList
            
            for value in dict! {
                let exerciseItem = ExerciseItem(exerciseID: "\(value["exerciseID"] ?? 0)", exerciseName: "\(value["exerciseName"] ?? "")", exerciseWeightAmount: Float("\(value["Weight Amount"] ?? 0)")!, exerciseCount: Float("\(value["Count"] ?? 0)")!, exerciseReps: Int("\(value["Reps"] ?? 0)")!, exerciseSets: Int("\(value["Sets"] ?? 0)")!, exerciseTime: Int("\(value["Time"] ?? 0)")!, exerciseDistance: Int("\(value["Distance"] ?? 0)")!, exerciseComment: "\(value["Exercise Comment"] ?? "")")
                
                array.append(exerciseItem)
            }
            self.dict = session._exerciseList!
            //print("Original Dict: ", dict)
            //print("Original List: ", session._exerciseList)
            tableView.reloadData()
        }
        else {
            tableView.isHidden = true
            sessionActivitiesLabel.isHidden = false
        }
    }
    
    @objc func back() {
        print("This is the back")
        if session._exerciseList != nil {
            print("Count for original list: ", originalExerciseList.count)
            print("Count for new list: ", session._exerciseList!.count)
            if session._exerciseList?.count != self.originalExerciseList.count {
                showConfirmAlert()
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func updateExercise(notification: Notification) {
        getActivities()
    }
    
    @objc func updateTableView(notification: Notification) {
        print("Got notification")
        print("Here notification")
        if let responseDict = notification.object as? [String: Any] {
            self.dict.append(responseDict)
            print("Inside If")
            print(dict.count)
            print("Dict Weight: ", Float("\(responseDict["Weight Amount"])"))
            let exerciseItem = ExerciseItem(exerciseID: "\(responseDict["exerciseID"] ?? 0)", exerciseName: "\(responseDict["exerciseName"] ?? "")", exerciseWeightAmount: Float("\(responseDict["Weight Amount"] ?? 0)")!, exerciseCount: Float("\(responseDict["Count"] ?? 0)")!, exerciseReps: Int("\(responseDict["Reps"] ?? 0)")!, exerciseSets: Int("\(responseDict["Sets"] ?? 0)")!, exerciseTime: Int("\(responseDict["Time"] ?? 0)")!, exerciseDistance: Int("\(responseDict["Distance"] ?? 0)")!, exerciseComment: "\(responseDict["Exercise Comment"] ?? "")")
            array.append(exerciseItem)
            sessionActivitiesLabel.isHidden = true
            tableView.reloadData()
            session._exerciseList = self.dict
            print("Exercise Item Weight: ", exerciseItem.exerciseWeightAmount)
            //print("Updated Dict: ", self.dict)
            //print("Updated List: ", self.session._exerciseList)
        }
        else {
            print("Not inside If")
        }
    }

    @objc func saveSession() {
        if session._exerciseList != nil {
            self.showHUD(hud: hud!)
            print(session)
            session.createActivity(activityItem: session) { (response) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                }
                if response == "success" {
                    DispatchQueue.main.async {
                        self.showSuccessHUD(text: "Session updated")
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: .refreshActivity3, object: nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.showErrorHUD(text: response)
                    }
                }
                
            }
        }
        else {
            DispatchQueue.main.async {
                self.showErrorHUD(text: "Please add an acitivty first")
            }
        }
    }
    
    @objc func goToExerciseDetailsVC() {
        let storyboard = UIStoryboard(name: "AddActivityInSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "ExerciseDetailsVC") as! ExerciseDetailsVC
        destVC.session = session
        destVC.cameFromSessionActivities = true
        self.present(destVC, animated: true, completion: .none)
    }
    

}
