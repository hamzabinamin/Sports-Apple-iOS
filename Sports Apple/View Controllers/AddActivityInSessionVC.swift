//
//  AddActivityInSessionVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/3/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JGProgressHUD

class AddActivityInSessionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activitiesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var session: Activity = Activity()
    var dict: [[String: Any]] = []
    var array: [ExerciseItem] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if array.count == 0 {
            activitiesLabel.isHidden = false
        }
        else {
            activitiesLabel.isHidden = true
        }
        
         NotificationCenter.default.addObserver(self, selector: #selector(updateTableView(notification:)), name: .updateActivityTV, object: nil)
        
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

    func setupViews() {
        self.hud = self.createLoadingHUD()
        self.tableView.tableFooterView = UIView()
        addButton.addTarget(self, action: #selector(goToExerciseDetailsVC), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveSession), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func updateTableView(notification: Notification) {
        //array = dict.map { $0 }.sorted { $0 < $1.key }
        print("Got notification")
        if let responseDict = notification.object as? [String: Any] {
            dict.append(responseDict)
            print("Inside If")
            print(dict.count)
          /*  for (key,value) in responseDict {
                
                print()
                
               print("exerciseID: ", "\(value["exerciseID"])")
                print("exerciseName: ", "\(value["exerciseName"])")
                print("exerciseWeightAmount: ", Int("\(value["Weight Amount"])"))
                print("exerciseCount: ", Int("\(value["Count"])"))
                print("exerciseReps: ", Int("\(value["Reps"])"))
                print("exerciseSets: ", Int("\(value["Sets"])"))
                print("exerciseTime: ", Int("\(value["Time"])"))
                print("exerciseDistance: ", Int("\(value["Distance"])"))
                print("exerciseComment: ", "\(value["Exercise Comment"])")
                
                let exerciseItem = ExerciseItem(exerciseID: "\(key["exerciseID"] ?? 0)", exerciseName: "\(value["exerciseName"] ?? "")", exerciseWeightAmount: Int("\(value["Weight Amount"] ?? 0)")!, exerciseCount: Int("\(value["Count"] ?? 0)")!, exerciseReps: Int("\(value["Reps"] ?? 0)")!, exerciseSets: Int("\(value["Sets"] ?? 0)")!, exerciseTime: Int("\(value["Time"] ?? 0)")!, exerciseDistance: Int("\(value["Distance"] ?? 0)")!, exerciseComment: "\(value["Exercise Comment"] ?? "")")
                
               // array.append(exerciseItem)
            } */
            
            let exerciseItem = ExerciseItem(exerciseID: "\(responseDict["exerciseID"] ?? 0)", exerciseName: "\(responseDict["exerciseName"] ?? "")", exerciseWeightAmount: Int("\(responseDict["Weight Amount"] ?? 0)")!, exerciseCount: Int("\(responseDict["Count"] ?? 0)")!, exerciseReps: Int("\(responseDict["Reps"] ?? 0)")!, exerciseSets: Int("\(responseDict["Sets"] ?? 0)")!, exerciseTime: Int("\(responseDict["Time"] ?? 0)")!, exerciseDistance: Int("\(responseDict["Distance"] ?? 0)")!, exerciseComment: "\(responseDict["Exercise Comment"] ?? "")")
            array.append(exerciseItem)
            activitiesLabel.isHidden = true
            tableView.reloadData()
            session._exerciseList = dict
        }
        else {
            print("Not inside If")
        }
    }
    
    @objc func saveSession() {
        if session._exerciseList != nil {
        self.showHUD(hud: hud!)
        session.createActivity(activityItem: session) { (response) in
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            if response == "success" {
                DispatchQueue.main.async {
                    self.showSuccessHUD(text: "Session added")
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: .sessionAdded, object: nil)
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
        self.present(destVC, animated: true, completion: .none)
    }
    
    

    
}
