//
//  GoalsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/6/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class GoalsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var array: [GoalsItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAddImageView()
        
        array.append(GoalsItem(activity: "Arnold Press", goalType: "Weight Goal", goalAmount: 18))
        array.append(GoalsItem(activity: "Bench Press", goalType: "Weight Goal", goalAmount: 20))
        array.append(GoalsItem(activity: "Plank", goalType: "Time Goal", goalAmount: 240000))
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GoalsTVCell
        cell.activityLabel.text = array[indexPath.row].activity
        cell.goalTypeLabel.text = array[indexPath.row].goalType
        
        if array[indexPath.row].goalType == "Time Goal" {
            cell.goalAmountLabel.text = array[indexPath.row].goalAmount.msToSeconds.minuteSecond
        }
        else if array[indexPath.row].goalType == "Weight Goal" {
            cell.goalAmountLabel.text = String(array[indexPath.row].goalAmount) + " KG"
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setupAddImageView() {
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
