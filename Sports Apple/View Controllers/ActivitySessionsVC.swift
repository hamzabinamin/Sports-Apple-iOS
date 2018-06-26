//
//  ActivitySessionsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/2/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ActivitySessionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var forwardImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintHeading: NSLayoutConstraint!
    @IBOutlet weak var constraintAddImageView: NSLayoutConstraint!
    var array: [SessionItem] = []
    var pool: AWSCognitoIdentityUserPool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTaps()
        rotateArrow()
        array.append(SessionItem(sessionDate: "30th May, 2018", sessionLocation: "At the Gym", sessionBodyWeight: "64 KG", sessionCalories: "516", sessionComment: "Great Session!!!"))
        array.append(SessionItem(sessionDate: "30th May, 2018", sessionLocation: "At Home", sessionBodyWeight: "64 KG", sessionCalories: "499", sessionComment: "None"))
        
        //let exercise = Exercise()
        //exercise?.queryExercise()
        //exercise?.scanExercises()
        //exercise?.createExercise()
        //let store = UtilityFunctions.getExercises()
        //print(store.count)
        //print(store[0]._exerciseId)
        //print(store[0]._name)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SessionTVCell
        cell.bodyWeightLabel.text = array[indexPath.row].sessionBodyWeight
        cell.caloriesLabel.text = array[indexPath.row].sessionCalories
        cell.locationLabel.text = "(" + array[indexPath.row].sessionLocation + ")"
        cell.sessionCommentLabel.text = array[indexPath.row].sessionComment
        cell.nextImageView.transform = CGAffineTransform(rotationAngle: .pi);
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToSessionActivitiesVC))
        cell.nextImageView.isUserInteractionEnabled = true
        cell.nextImageView.addGestureRecognizer(tap)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func rotateArrow() {
        self.forwardImageView.transform = CGAffineTransform(rotationAngle: .pi);
    }
    
    func setupTaps() {
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        let tapPrev = UITapGestureRecognizer(target: self, action: #selector(previousDate))
        let tapNext = UITapGestureRecognizer(target: self, action: #selector(nextDate))
        let tapAdd = UITapGestureRecognizer(target: self, action: #selector(goToAddSessionVC))
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tapPrev)
        forwardImageView.isUserInteractionEnabled = true
        forwardImageView.addGestureRecognizer(tapNext)
        addImageView.isUserInteractionEnabled = true
        addImageView.addGestureRecognizer(tapAdd)
    }
    
    @objc func previousDate() {
        
    }
    
    @objc func nextDate() {
        
    }
    
    @objc func goToAddSessionVC() {
        let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddSessionVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToSessionActivitiesVC() {
        let storyboard = UIStoryboard(name: "SessionActivities", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SessionActivitiesVC")
        self.present(destVC, animated: true, completion: .none)
    }
}
