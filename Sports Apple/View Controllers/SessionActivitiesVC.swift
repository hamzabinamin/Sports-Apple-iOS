//
//  SessionActivitiesVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class SessionActivitiesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var array: [ExerciseItem] = []
    let e1 = ExerciseItem(exerciseID: "1", exerciseName: "Deadlift", exerciseWeightAmount: 25, exerciseCount: 0, exerciseReps: 12, exerciseSets: 3, exerciseTime: 0, exerciseDistance: 0, exerciseComment: "Great workout")
    let e2 = ExerciseItem(exerciseID: "1", exerciseName: "Running", exerciseWeightAmount: 0, exerciseCount: 0, exerciseReps: 0, exerciseSets: 0, exerciseTime: 0, exerciseDistance: 1200, exerciseComment: "What a run!")
    let e3 = ExerciseItem(exerciseID: "1", exerciseName: "Cycling", exerciseWeightAmount: 0, exerciseCount: 0, exerciseReps: 0, exerciseSets: 0, exerciseTime: 245400, exerciseDistance: 0, exerciseComment: "Feeling pumped")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTaps()
        array.append(e1)
        array.append(e2)
        array.append(e3)
       
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
            cell.distanceTimeLabel.isHidden = true
            
            cell.weightLabel.text = String(array[indexPath.row].exerciseWeightAmount) + " KG"
            cell.setsLabel.text = String(array[indexPath.row].exerciseSets) + " Sets"
            cell.repsLabel.text = String(array[indexPath.row].exerciseReps) + " Reps"
            
            if array[indexPath.row].exerciseCount != 0 {
                cell.countsLabel.isHidden = false
                cell.setsLabel.isHidden = true
                cell.repsLabel.isHidden = true
                cell.countsLabel.text = String(array[indexPath.row].exerciseCount)
            }
            else {
                cell.countsLabel.isHidden = true
                cell.setsLabel.isHidden = false
                cell.repsLabel.isHidden = false
            }
        }
        else if array[indexPath.row].exerciseDistance != 0 {
            
            cell.weightLabel.isHidden = true
            cell.setsLabel.isHidden = true
            cell.repsLabel.isHidden = true
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = false
            
            cell.distanceTimeLabel.text = String(array[indexPath.row].exerciseDistance) + "\n Miles"
        }
        else if array[indexPath.row].exerciseTime != 0 {
            cell.weightLabel.isHidden = true
            cell.setsLabel.isHidden = true
            cell.repsLabel.isHidden = true
            cell.countsLabel.isHidden = true
            cell.distanceTimeLabel.isHidden = false
            cell.distanceTimeLabel.text = array[indexPath.row].exerciseTime.msToSeconds.minuteSecond
        }
        
        
        
        return cell
    }
    
    func setupTaps() {
        let tapBack = UITapGestureRecognizer(target: self, action: #selector(back))
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tapBack)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

    

}
